module TohsakaBot
  class RemindmeCore
    include ActionView::Helpers::DateHelper
    DURATION_REGEX = /^[ydwhmseckin0-9-]*$/i
    DATE_REGEX = /^[0-9]{4}-(1[0-2]|0[1-9])-(3[0-2]|[1-2][0-9]|0[1-9])\s(2[0-4]|1[0-9]|0[0-9]):(60|[0-5][0-9]):(60|[0-5][0-9])/
    # attr_reader :datetime, :msg, :userid, :channelid, :repeated

    def initialize(event, time_input, msg)
      @event = event
      @datetime = time_input
      @msg = msg.join(' ').strip_mass_mentions.sanitize_string
      @userid = event.message.user.id
      @channelid = event.channel.id
      @repeat = 'false'
      @time_msg_separatos = %w[;]
    end

    def convert_datetime
      # If the reminder is to be repeated.
      if @datetime[0] == 'R' || @datetime[0] == 'r'
        @repeat = ''
        @datetime[0] = ''
      end

      long_natural_time = @datetime + " " + @msg
      splitter = ""

      # Input as natural language (spaces allowed)
      if @time_msg_separatos.any? { |s| long_natural_time.include?(splitter = s)}
        splitted = long_natural_time.split(splitter, 2)
        @datetime = Chronic.parse(splitted[0].gsub(splitter, ''))
        @msg = splitted[1]
        @msg[0] = "" if @msg[0] == " " # Remove an unnecessary space
        return 0 if @datetime.nil?
        @datetime.to_i > Time.now.to_i ? 1 : 2 # && DATE_REGEX.match?(datetime.to_s)

      # The input is a duration (e.g. 5d4h30s)
      elsif DURATION_REGEX.match?(@datetime.to_s)

        # Format P(n)Y(n)M(n)W(n)DT(n)H(n)M(n)S
        seconds = match_time(@datetime, /([0-9]*)(sec|sek|[sS])/) || 0
        minutes = match_time(@datetime,      /([0-9]*)(min|[m])/) || 0
        hours   = match_time(@datetime,         /([0-9]*)([hH])/) || 0
        days    = match_time(@datetime,         /([0-9]*)([dD])/) || 0
        weeks   = match_time(@datetime,         /([0-9]*)([wW])/) || 0
        months  = match_time(@datetime,          /([0-9]*)([M])/) || 0
        years   = match_time(@datetime,        /([0-9]*)([yYa])/) || 0

        # Because weeks cannot be used at the same time as years, months or days.
        if weeks.to_i == 0
          iso8601_time = if "#{hours}#{minutes}#{seconds}".to_s.empty?
                           "P#{years}Y#{months}M#{days}D"
                         else
                           "P#{years}Y#{months}M#{days}DT#{hours}H#{minutes}M#{seconds}S"
                         end
        elsif weeks.to_i > 0 && years == 0 && months == 0 && days == 0
          iso8601_time = if "#{hours}#{minutes}#{seconds}".to_s.empty?
                           "P#{weeks}W"
                         else
                           "P#{weeks}WT#{hours}H#{minutes}M#{seconds}S"
                         end
        else
          return 4
        end

        parsed_time = ActiveSupport::Duration.parse(iso8601_time)
        if @repeat != 'false'
          @repeat = parsed_time.seconds
          return 5 if parsed_time.seconds.to_i < 600
        end

        @datetime = parsed_time.seconds.from_now
        @datetime > Time.now && DATE_REGEX.match?(parsed_time.seconds.from_now.to_s) ? 1 : 3

      # Direct ISO 8601 formatted input
      elsif DATE_REGEX.match?("#{@datetime.gsub('_', ' ')} #{@msg}")
        @datetime = Time.parse(@datetime.gsub('_', ' ')).to_i
        @datetime > Time.now.to_i ? 1 : 2

      # Input as a natural word (no spaces)
      else
        @datetime = Chronic.parse(@datetime)
        return 0 if @datetime.nil?
        @datetime.to_i > Time.now.to_i ? 1 : 2 # && DATE_REGEX.match?(datetime.to_s)
      end
    end

    def match_time(time, regex)
      if time.match(regex)
        time.scan(regex)[0][0]
      end
    end

    def store_reminder
      reminders_db = YAML::Store.new('data/reminders.yml')
      repeated_msg = @repeat != "false" ? "repeatedly " : ''
      repetition_interval = @repeat != "false" ? " `<Interval #{distance_of_time_in_words(@repeat)}>`" : ''
      i = 1
      reminders_db.transaction do
        i += 1 while reminders_db.root?(i)
        reminders_db[i] = {
            "time"    => @datetime.to_i,
            "message" => @msg.to_s,
            "user"    => @userid.to_s,
            "channel" => @channelid.to_s,
            "repeat"  => @repeat.to_s
        }
        reminders_db.commit
      end

      # If the date was in the ISO 8601 format, convert it to text for the message.
      @datetime = @datetime.is_a?(Integer) ? @datetime = Time.at(@datetime) : @datetime
      if @msg.empty?
        @event.respond "I shall #{repeated_msg}remind <@#{@userid.to_i}> at `#{@datetime}` `<ID #{i}>`#{repetition_interval}. "
      else
        @event.respond "I shall #{repeated_msg}remind <@#{@userid.to_i}> with #{@msg.hide_link_preview} at `#{@datetime}` `<ID #{i}>`#{repetition_interval}."
      end
      unless @event.channel.pm?
        @event.message.delete
      end
    end
  end
end
