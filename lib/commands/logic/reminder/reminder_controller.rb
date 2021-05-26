# frozen_string_literal: true

module TohsakaBot
  class ReminderController
    include ActionView::Helpers::DateHelper
    DURATION_REGEX = /^[ydwhmMsSeckin0-9-]*$/i.freeze
    DATE_REGEX = /^[0-9]{4}-(1[0-2]|0[1-9])-(3[0-2]|[1-2][0-9]|0[1-9])\s
                  (2[0-4]|1[0-9]|0[0-9]):(60|[0-5][0-9]):(60|[0-5][0-9])/x.freeze

    def initialize(event, id, legacy, datetime = nil, msg = nil, repeat = nil, channel_id = nil)
      # TODO: Fix this when there's one unmatched quote in the reminder message
      # tjoo toi option parser ei tykkää tost ja ei pääse koko logiikka ees tonne legacy hommaan asti
      # mies rescuee ton ja heittää legacy koodin hoidettavaks
      # ?remindme 15h6m35s CAN'T DO THIS!
      # <ArgumentError: Unmatched double quote: "15h6m35s CAN'T DO THIS">
      # 2020-11-02 21:53:24.801 ct-322  ✗ lib/helpers/core_helper.rb:27:in `command_parser'
      # 2020-11-02 21:53:24.801 ct-322  ✗ lib/commands/remindme/reminder_add.rb:18:in `block in <module:ReminderAdd>'
      if legacy
        @datetime = datetime[0]
        @msg = datetime[1].strip_mass_mentions.sanitize_string unless datetime[1].nil?
      else
        @datetime = datetime unless datetime.nil?
        @msg = msg.strip_mass_mentions.sanitize_string unless msg.nil?
      end

      @event = event
      @discord_uid = TohsakaBot.command_event_user_id(event)
      @channel_id = channel_id.to_i

      if !repeat.nil?
        minutes = match_time(repeat, /([0-9]*)(min|m)/) || 0
        hours   = match_time(repeat,    /([0-9]*)([hH])/) || 0
        days    = match_time(repeat,    /([0-9]*)([dD])/) || 0

        @repeat = (minutes * 60) + (hours * 60 * 60) + (days * 24 * 60 * 60)
      else
        @repeat = 0
      end

      @id = id
    end

    def convert_datetime
      return if @datetime.nil?

      # The input is a duration (e.g. 5d4h30s)
      if DURATION_REGEX.match?(@datetime.to_s)
        # Format P(n)Y(n)M(n)W(n)DT(n)H(n)M(n)S
        seconds = match_time(@datetime, /([0-9]*)(sec|sek|[sS])/) || 0
        minutes = match_time(@datetime, /([0-9]*)(min|m)/) || 0
        hours   = match_time(@datetime, /([0-9]*)([hH])/) || 0
        days    = match_time(@datetime, /([0-9]*)([dD])/) || 0
        weeks   = match_time(@datetime, /([0-9]*)([wW])/) || 0
        months  = match_time(@datetime, /([0-9]*)(M)/) || 0
        years   = match_time(@datetime, /([0-9]*)([yYa])/) || 0

        # Because weeks cannot be used at the same time as years, months or days.
        if weeks.zero?
          iso8601_time = if "#{hours}#{minutes}#{seconds}".empty?
                           "P#{years}Y#{months}M#{days}D"
                         else
                           "P#{years}Y#{months}M#{days}DT#{hours}H#{minutes}M#{seconds}S"
                         end
        elsif weeks.positive? && years.zero? && months.zero? && days.zero?
          iso8601_time = if "#{hours}#{minutes}#{seconds}".empty?
                           "P#{weeks}W"
                         else
                           "P#{weeks}WT#{hours}H#{minutes}M#{seconds}S"
                         end
        else
          raise ReminderHandler::WeeksMixedError
        end

        parsed_time = ActiveSupport::Duration.parse(iso8601_time)
        raise ReminderHandler::DateTimeSyntaxError if parsed_time.seconds <= 0

        @datetime = parsed_time.from_now

      # Direct ISO 8601 formatted input
      elsif DATE_REGEX.match?("#{@datetime.gsub('_', ' ')} #{@msg}")
        @datetime = Time.parse(@datetime.gsub('_', ' ')).to_i

      # Input as a natural word (no spaces)
      else
        @datetime = Chronic.parse(@datetime)
      end

      raise ReminderHandler::DateTimeSyntaxError if !DATE_REGEX.match?(@datetime.to_s) || @datetime.nil?
      raise ReminderHandler::MaxTimeError if @datetime.year > 9999
      raise ReminderHandler::PastError if @datetime < Time.now

      ReminderHandler.handle_repeat_limit(@repeat, BOT.channel(@channel_id).pm?) if @repeat.positive?
    end

    def match_time(time, regex)
      time.scan(regex)[0][0].to_i if time.match(regex)
    end

    def store_reminder
      return unless TohsakaBot.registered?(@discord_uid)

      reminders = TohsakaBot.db[:reminders]
      TohsakaBot.db.transaction do
        @id = reminders.insert(
          datetime: @datetime,
          message: @msg,
          user_id: TohsakaBot.get_user_id(@discord_uid),
          channel_id: @channel_id,
          repeat: @repeat,
          created_at: Time.now,
          updated_at: Time.now
        )
      end

      repetition_interval = @repeat.positive? ? " `<Interval #{distance_of_time_in_words(@repeat)}>`" : ''

      final_response(repetition_interval, false)
    end

    def update_reminder
      return unless TohsakaBot.registered?(@discord_uid)

      reminders = TohsakaBot.db[:reminders]
      reminder = reminders.where(id: @id.to_i).single_record!

      if @datetime.nil?
        @datetime = reminder[:datetime]
      else
        reminder[:datetime] = @datetime
      end
      if @msg.nil?
        @msg = reminder[:message]
      else
        reminder[:message] = @msg
      end
      if @channel_id.nil? || @channel_id.zero?
        @channel_id = reminder[:channel_id]
      else
        reminder[:channel_id] = @channel_id
      end
      if @repeat.nil?
        @repeat = reminder[:repeat]
      else
        reminder[:repeat] = @repeat
      end

      TohsakaBot.db.transaction do
        reminders.where(id: @id.to_i).update(reminder)
      end

      repetition_interval = if @repeat.positive?
                              I18n.t(:'commands.reminder.add.repeat_interval',
                                     interval: distance_of_time_in_words(@repeat))
                            else
                              ""
                            end

      final_response(repetition_interval, true)
    end

    def final_response(repetition_interval, mod)
      # If the date was in the ISO 8601 format, convert it to text for the message.
      @datetime = @datetime.is_a?(Integer) ? @datetime = Time.at(@datetime) : @datetime

      msg_beginning = mod ? "Modified reminder for" : "I shall"
      msg_ending = mod ? " in <##{@channel_id}>." : "."
      repeated_msg = repetition_interval.empty? ? "" : "repeatedly"

      if @msg.blank?
        "#{msg_beginning} #{repeated_msg}remind <@#{@discord_uid.to_i}> "\
        "at `#{@datetime}` `<ID #{@id}>`#{repetition_interval}."
      else
        "#{msg_beginning} #{repeated_msg}remind <@#{@discord_uid.to_i}> with #{@msg.strip.hide_link_preview} "\
        "at `#{@datetime}` `<ID #{@id}>`#{repetition_interval}#{msg_ending}"
      end
    end

    def self.copy_reminder(reminder_id, discord_uid)
      discord_uid = discord_uid.to_i
      reminder_id = reminder_id.to_i
      return unless TohsakaBot.registered?(discord_uid)

      reminders = TohsakaBot.db[:reminders]
      reminder = reminders.where(id: reminder_id.to_i).single_record
      id = nil
      unless reminder.nil?
        TohsakaBot.db.transaction do
          id = reminders.insert(datetime: reminder[:datetime],
                                message: reminder[:message],
                                user_id: TohsakaBot.get_user_id(discord_uid),
                                channel_id: reminder[:channel_id],
                                repeat: reminder[:repeat],
                                parent: reminder_id,
                                created_at: Time.now,
                                updated_at: Time.now)
        end
      end
      id
    end

    def self.copy_already_exists?(reminder_id, discord_uid)
      discord_uid = discord_uid.to_i
      reminder_id = reminder_id.to_i

      reminders = TohsakaBot.db[:reminders]

      !reminders.where(parent: reminder_id.to_i, user_id: TohsakaBot.get_user_id(discord_uid)).single_record.nil?
    end

    def self.get_reminder(id)
      TohsakaBot.db[:reminders].where(id: id.to_i).single_record
    end
  end
end
