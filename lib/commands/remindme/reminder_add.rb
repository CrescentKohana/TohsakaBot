module TohsakaBot
  module Commands
    module ReminderAdd
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: %i[remind reminder remadd remind addrem muistuta muistutus rem],
              description: 'Sets a reminder.',
              usage: 'remindme '\
                      '--d(atetime) <yMwdhms || dd/mm/yyyy hh.mm.ss || natural language> '\
                      '--m(essage) <msg (text)> '\
                      '--r(epeat) <dhm (duration, eg. 2d6h20m)>',
              min_args: 1,
              require_register: true) do |event, *msg|

        args = msg.join(' ')
        options = {}
        legacy = false

        begin
          OptionParser.new do |opts|
            opts.on('--datetime DATETIME', String)
            opts.on('--message MESSAGE', String)
            opts.on('--repeat REPEAT', String)
          end.parse!(Shellwords.shellsplit(args), into: options)
        rescue OptionParser::InvalidOption => e
          event.respond "Tried to use an #{e}."
          break
        end

        datetime = options[:datetime]
        if datetime.blank? && (!options[:message].blank? || !options[:repeat].blank?)
          event.respond 'If specifying other options (--m, --r), --d cannot be blank.'
          break
        elsif datetime.blank?
          if args.include? ';'
            datetime = args.split(';', 2)
          else
            datetime = args.split(' ', 2)
          end
          legacy = true
        end

        rem = ReminderController.new(event, datetime, options[:message], options[:repeat], legacy)
        discord_uid = event.message.user.id.to_i

        begin
          ReminderHandler.handle_user_limit(discord_uid)
        rescue ReminderHandler::UserLimitReachedError => e
          event.respond e.message
          break
        end

        begin
          rem.convert_datetime
        rescue ReminderHandler::DatetimeError, ReminderHandler::RepeatIntervalError => e
          event.respond e.message
          break
        end

        rem.store_reminder
      end
    end
  end
end
