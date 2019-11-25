module TohsakaBot
  module Commands
    module RemindMe
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: %i[remind reminder remadd remind addrem muistuta muistutus rem],
              description: 'Reminder.',
              min_args: 1,
              usage: 'remindme <R01y01M01w01d01h01m01s||yyyy-MM-dd_hh:mm:ss> <msg> (R for repeated, >10 minutes)',
              rescue: "Something went wrong!\n`%exception%`") do |event, time_input, *msg|

        rem = RemindMeCore.new(event, time_input, msg)
        output = rem.convert_datetime
        m = 'Usage: `remindme <R01y01M01w01d01h01m01s||natural language||ISO8601 etc.> <msg> (R for repeated, >10 minutes)`'

        if rem.user_limit_reached?
          m = "Sorry, but the the limit for remainders per user is #{$settings['remainder_limit']}! "
          + "Wait that they expire or remove them with `reminders` & `delreminder <id(s)>`."
          output = 0
        end

        case output
        when 1 # Success!
          m = rem.store_reminder
        when 2 # Past value (or exactly now)
          m = 'The thing is.. time travel is still a little hard for me :(, so try not to use past dates. ' + m
        when 3 # Negative value
          m = 'The thing is.. time travel is still a little hard for me :(, so try not to use negative values. ' + m
        when 4 # Limitation of a Gem
          m = 'Mixing weeks with other date parts (y, M, d) is not allowed.'
        when 5 # So no spam
          m = 'The interval limit for repeated reminders is ten minutes. Reminder aborted.'
        end

        event.<< m
      end
    end
  end

  class RemindMeCore
    DURATION_REGEX = /^[ydwhmseckin0-9-]*$/i
    DATE_REGEX = /^[0-9]{4}-(1[0-2]|0[1-9])-(3[0-2]|[1-2][0-9]|0[1-9])\s(2[0-4]|1[0-9]|0[0-9]):(60|[0-5][0-9]):(60|[0-5][0-9])/
    # attr_reader :datetime, :msg, :userid, :channelid, :repeated

    def initialize(event, time_input, msg)
      @event = event
      @datetime = time_input
      @msg = msg.join(' ').strip_mass_mentions.sanitize_string || time_input.split(';')[1]
      @userid = event.message.user.id
      @channelid = event.channel.id
      @repeat = 'false'
    end

    def convert_datetime
      # If the reminder is to be repeated.
      if @datetime[0] == 'R' && @datetime[0] == 'r'
        @repeat = ''
        @datetime[0] = ''
      end

      long_natural_time = @datetime + " " + @msg

      # Input as natural language (spaces allowed)
      if long_natural_time.include? ';'

        splitted = long_natural_time.split(';')
        @datetime = Chronic.parse(splitted[0].gsub(';', ''))
        @msg = splitted[1]
        @msg[0] = "" if @msg[0] == " " # Remove an unnecessary space

        return 0 if @datetime.nil?
        @datetime.to_i > Time.now.to_i ? 1 : 2 # && DATE_REGEX.match?(datetime.to_s)

        # The input is a duration
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

        @datetime = "#{@datetime.gsub('_', ' ')}"
        Time.parse(@datetime).to_i > Time.now.to_i && DATE_REGEX.match?(@datetime.to_s) ? 1 : 2

        # Input as a natural word (only one)
      else
        @datetime = Chronic.parse(@datetime)

        return 0 if @datetime.nil?
        @datetime.to_i > Time.now.to_i ? 1 : 2 # && DATE_REGEX.match?(datetime.to_s)
      end
    end

    def user_limit_reached?
      all = YAML.load_file('data/reminders.yml')
      reminders_amount = 0

      all.each do |k, v|
        if @userid == v["user"].to_i
          reminders_amount += 1
        end
      end

      reminders_amount >= $settings['remainder_limit'].to_i
    end

    def match_time(time, regex)
      if time.match(regex)
        time.scan(regex)[0][0]
      end
    end

    def store_reminder
      reminders_db = YAML::Store.new('data/reminders.yml')
      repeated_msg = @repeat != "false" ? "repeatedly " : ''
      # TODO: Convert seconds to a better format below.
      repetition_interval = @repeat != "false" ? " Interval #{@repeat}s." : ''

      i = 1
      reminders_db.transaction do
        while reminders_db.root?(i) do i += 1 end
        reminders_db[i] = {"time" => @datetime.to_i,
                           "message" => "#{@msg}",
                           "user" => "#{@userid}",
                           "channel" =>"#{@channelid}",
                           "repeat" =>"#{@repeat}" }
        reminders_db.commit
      end

      if @msg.empty?
        @event.respond "I shall #{repeated_msg}remind <@#{@userid.to_i}> at `#{@datetime}` `<ID: #{i}>`.#{repetition_interval} "
      else
        @event.respond "I shall #{repeated_msg}remind <@#{@userid.to_i}> with #{@msg.hide_link_preview} at `#{@datetime}` `<ID: #{i}>`.#{repetition_interval}"
      end

      unless @event.channel.pm?
        @event.message.delete
      end
    end
  end
end
