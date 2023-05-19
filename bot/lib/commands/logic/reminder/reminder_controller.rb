# frozen_string_literal: true

require 'chronic'

module TohsakaBot
  class ReminderController
    include ActionView::Helpers::DateHelper

    # attr_reader @datetime

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
      @discord_uid = event.nil? ? nil : TohsakaBot.command_event_user_id(event)
      @channel_id = channel_id.to_i
      @user_id = @discord_uid.nil? ? nil : TohsakaBot.get_user_id(@discord_uid)
      @timezone = TohsakaBot.get_timezone(@user_id)
      @time_now = TohsakaBot.time_now(@timezone)

      if !repeat.nil?
        minutes = TohsakaBot.match_time(repeat, /([0-9]*)(min|m)/) || 0
        hours   = TohsakaBot.match_time(repeat,    /([0-9]*)([hH])/) || 0
        days    = TohsakaBot.match_time(repeat,    /([0-9]*)([dD])/) || 0

        @repeat = (minutes * 60) + (hours * 60 * 60) + (days * 24 * 60 * 60)
      else
        @repeat = 0
      end

      @id = id
    end

    def convert_datetime(time_now = @time_now)
      return if @datetime.nil?

      is_utc = false

      # Duration input (e.g. 5d4h30s)
      if DURATION_REGEX.match?(@datetime.to_s)
        # Format P(n)Y(n)M(n)W(n)DT(n)H(n)M(n)S
        seconds = TohsakaBot.match_time(@datetime, /([0-9]*)(sec|sek|[sS])/) || 0
        minutes = TohsakaBot.match_time(@datetime, /([0-9]*)(min|m)/) || 0
        hours   = TohsakaBot.match_time(@datetime, /([0-9]*)([hH])/) || 0
        days    = TohsakaBot.match_time(@datetime, /([0-9]*)([dD])/) || 0
        weeks   = TohsakaBot.match_time(@datetime, /([0-9]*)([wW])/) || 0
        months  = TohsakaBot.match_time(@datetime, /([0-9]*)(M)/) || 0
        years   = TohsakaBot.match_time(@datetime, /([0-9]*)([yYa])/) || 0

        # Weeks cannot be used at the same time as years, months or days.
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

        @datetime = parsed_time.since(time_now)

      # ISO8601-like input
      elsif DATE_REGEX.match?("#{@datetime.gsub('_', ' ')} #{@msg}")
        @datetime = Time.parse(@datetime.gsub('_', ' '))
        is_utc = true

      # Natural language input
      else
        @datetime = Chronic.parse(@datetime, { now: time_now, hours24: true, endian_precedence: %i[little middle] })
        is_utc = true

      end

      raise ReminderHandler::DateTimeSyntaxError if @datetime.nil? || !DATE_REGEX.match?(@datetime.to_s)
      raise ReminderHandler::MaxTimeError if @datetime.year > 9999

      @datetime = @datetime.asctime.in_time_zone(@timezone) if is_utc
      raise ReminderHandler::PastError if @datetime < time_now
      @datetime = @datetime.utc

      @datetime
    end

    def enforce_repeat_limits
      ReminderHandler.handle_repeat_limit(@repeat, BOT.channel(@channel_id).pm?) if @repeat.positive?
    end

    def store_reminder
      return unless TohsakaBot.registered?(@discord_uid)

      reminders = TohsakaBot.db[:reminders]
      TohsakaBot.db.transaction do
        @id = reminders.insert(
          datetime: @datetime,
          timezone: @timezone,
          message: @msg,
          user_id: TohsakaBot.get_user_id(@discord_uid),
          channel_id: @channel_id,
          repeat: @repeat,
          created_at: TohsakaBot.time_now,
          updated_at: TohsakaBot.time_now
        )
      end

      repetition_interval = @repeat.positive? ? "`every #{distance_of_time_in_words(@repeat)}`" : ''

      { id: @id, content: final_response(repetition_interval, false) }
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
                              ''
                            end

      { id: @id, content: final_response(repetition_interval, true) }
    end

    def final_response(repetition_interval, mod)
      relative_time = Discordrb.timestamp(@datetime.to_i, :relative)
      # If the date was in the ISO 8601 format, convert it to text for the message.
      datetime = @datetime.is_a?(Integer) ? @datetime = Time.at(@datetime) : @datetime
      datetime = datetime.in_time_zone(@timezone)

      if mod
        reminder_type_msg = if repetition_interval.blank?
                              "reminder `<ID #{@id}>` "
                            else
                              "repeating reminder `<ID #{@id}>` #{repetition_interval} starting "
                            end

        return "<@#{@discord_uid.to_i}>, modified #{reminder_type_msg}at `#{datetime}` (#{relative_time}) "\
               "in <##{@channel_id}> with #{@msg.strip.hide_link_preview}"
      end

      reminder_type_msg = repetition_interval.empty? ? "" : "#{repetition_interval} starting "

      if @msg.blank?
        "`ID #{@id}` I shall remind <@#{@discord_uid.to_i}> #{reminder_type_msg}at `#{datetime}` #{relative_time}"
      else
        "`ID #{@id}` I shall remind <@#{@discord_uid.to_i}> #{reminder_type_msg}at `#{datetime}` #{relative_time}"\
        " with #{@msg.strip.hide_link_preview}"
      end
    end

    def self.copy_reminder(reminder_id, discord_uid)
      discord_uid = discord_uid.to_i
      reminder_id = reminder_id.to_i
      return unless TohsakaBot.registered?(discord_uid)

      reminders = TohsakaBot.db[:reminders]
      reminder = reminders.where(id: reminder_id.to_i).single_record
      id = nil
      return if reminder.nil?

      TohsakaBot.db.transaction do
        id = reminders.insert(datetime: reminder[:datetime],
                              timezone: reminder[:timezone],
                              message: reminder[:message],
                              user_id: TohsakaBot.get_user_id(discord_uid),
                              channel_id: reminder[:channel_id],
                              repeat: reminder[:repeat],
                              parent: reminder_id,
                              created_at: TohsakaBot.time_now,
                              updated_at: TohsakaBot.time_now)
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
