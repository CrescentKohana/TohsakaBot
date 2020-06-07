module TohsakaBot
  module Commands
    module ReminderAdd
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: %i[remind reminder remadd remind addrem muistuta muistutus rem],
              description: 'Sets a reminder.',
              usage: "Use 'remindme -h|--help' for help.",
              min_args: 1,
              require_register: true) do |event, *msg|

        options = TohsakaBot.command_parser(
            event, msg, 'Usage: remindme [options]', '',
            ['-d', '--datetime DATETIME', 'When to remind. Format: yMwdhms || dd/mm/yyyy hh.mm.ss || natural language', String],
            ['-m', '--message MESSAGE', 'Message for the reminder.', String],
            ['-r', '-repeat REPEAT', 'Interval duration for repeated reminders. Format: dhm (eg. 2d6h20m)', String]
        )
        break if options.nil?

        legacy = false
        datetime = options[:datetime]

        if datetime.blank? && (!options[:message].blank? || !options[:repeat].blank?)
          event.respond 'If specifying other options (--m, --r), --d cannot be blank.'
          break
        elsif datetime.blank?
          msg = msg.join(' ')
          if msg.include? ';'
            datetime = msg.split(';', 2)
          else
            datetime = msg.split(' ', 2)
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
