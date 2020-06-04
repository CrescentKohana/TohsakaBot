module TohsakaBot
  class ReminderController
    include ActionView::Helpers::DateHelper
    DURATION_REGEX = /^[ydwhmMsSeckin0-9-]*$/i
    DATE_REGEX = /^[0-9]{4}-(1[0-2]|0[1-9])-(3[0-2]|[1-2][0-9]|0[1-9])\s(2[0-4]|1[0-9]|0[0-9]):(60|[0-5][0-9]):(60|[0-5][0-9])/
    # attr_reader :datetime, :msg, :userid, :channelid, :repeated

    def initialize(event, time_input, msg, repeat, legacy)
      if legacy
        @datetime = time_input[0]
        @msg = time_input[1].strip_mass_mentions.sanitize_string unless time_input[1].nil?
      else
        @datetime = time_input
        @msg = msg.strip_mass_mentions.sanitize_string unless msg.nil?
      end

      @event = event
      @discord_uid = event.message.user.id
      @channelid = event.channel.id

      if !repeat.nil?
        minutes = match_time(repeat, /([0-9]*)(min|[m])/) || 0
        hours   = match_time(repeat,    /([0-9]*)([hH])/) || 0
        days    = match_time(repeat,    /([0-9]*)([dD])/) || 0

        @repeat = (minutes * 60) + (hours * 60 * 60) + (days * 24 * 60 * 60)
      else
        @repeat = 0
      end
    end

    def convert_datetime
      # The input is a duration (e.g. 5d4h30s)
      if DURATION_REGEX.match?(@datetime.to_s)
        # Format P(n)Y(n)M(n)W(n)DT(n)H(n)M(n)S
        seconds = match_time(@datetime, /([0-9]*)(sec|sek|[sS])/) || 0
        minutes = match_time(@datetime,      /([0-9]*)(min|[m])/) || 0
        hours   = match_time(@datetime,         /([0-9]*)([hH])/) || 0
        days    = match_time(@datetime,         /([0-9]*)([dD])/) || 0
        weeks   = match_time(@datetime,         /([0-9]*)([wW])/) || 0
        months  = match_time(@datetime,          /([0-9]*)([M])/) || 0
        years   = match_time(@datetime,        /([0-9]*)([yYa])/) || 0

        # Because weeks cannot be used at the same time as years, months or days.
        if weeks == 0
          iso8601_time = if "#{hours}#{minutes}#{seconds}".empty?
                           "P#{years}Y#{months}M#{days}D"
                         else
                           "P#{years}Y#{months}M#{days}DT#{hours}H#{minutes}M#{seconds}S"
                         end
        elsif weeks > 0 && years == 0 && months == 0 && days == 0
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

        @datetime = parsed_time.seconds.from_now

      # Direct ISO 8601 formatted input
      elsif DATE_REGEX.match?("#{@datetime.gsub('_', ' ')} #{@msg}")
        @datetime = Time.parse(@datetime.gsub('_', ' ')).to_i

      # Input as a natural word (no spaces)
      else
        @datetime = Chronic.parse(@datetime)
      end

      raise ReminderHandler::DateTimeSyntaxError if !DATE_REGEX.match?(@datetime.to_s) || @datetime.nil?
      raise ReminderHandler::PastError if @datetime < Time.now
      ReminderHandler.handle_repeat_limit(@repeat, BOT.channel(@channelid).pm?) if @repeat > 0
    end

    def match_time(time, regex)
      if time.match(regex)
        time.scan(regex)[0][0].to_i
      end
    end

    def store_reminder
      return unless TohsakaBot.registered?(@discord_uid)

      reminders = TohsakaBot.db[:reminders]
      TohsakaBot.db.transaction do
        @id = reminders.insert(datetime: @datetime,
                               message: @msg,
                               user_id: TohsakaBot.get_user_id(@discord_uid),
                               channel: @channelid,
                               repeat: @repeat,
                               created_at: Time.now,
                               updated_at: Time.now)
      end

      repeated_msg = @repeat > 0 ? "repeatedly " : ''
      repetition_interval = @repeat > 0 ? " `<Interval #{distance_of_time_in_words(@repeat)}>`" : ''

      # If the date was in the ISO 8601 format, convert it to text for the message.
      @datetime = @datetime.is_a?(Integer) ? @datetime = Time.at(@datetime) : @datetime
      if @msg.nil?
        @event.respond "I shall #{repeated_msg}remind <@#{@discord_uid.to_i}> at `#{@datetime}` `<ID #{@id}>`#{repetition_interval}. "
      else
        @event.respond "I shall #{repeated_msg}remind <@#{@discord_uid.to_i}> with #{@msg.hide_link_preview} at `#{@datetime}` `<ID #{@id}>`#{repetition_interval}."
      end
      unless @event.channel.pm?
        @event.message.delete
      end
    end
  end
end
