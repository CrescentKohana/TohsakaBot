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

        extra_help = "Alternatively, `remindme <time (if spaces put ; after this)> <msg>` also works.\n"\
                     "Example: `remindme -d 4M2d8h30s -m Tickets!` will remind you in 4 months, 2 days, 8 hours and 30 seconds for 'Tickets!'."

        options = TohsakaBot.command_parser(
            event, msg, 'Usage: remindme [options]', extra_help,
            [:datetime, "When to remind. Format: yMwdhms OR yyyy/MM/dd hh.mm.ss OR natural language", :type => :strings ],
            [:msg, "Message for the reminder.", :type => :strings ],
            [:repeat, "Interval duration for repeated reminders. Format: dhm (eg. 2d6h20m)", :type => :strings ]
        )
        break if options.nil?

        legacy = false
        datetime = options.datetime
        message = options.msg.nil? ? nil : options.msg.join(' ')
        repeat = options.repeat.nil? ? nil : options.repeat.join(' ')

        if datetime.blank? && (!options.msg.blank? || !options.repeat.blank?)
          event.respond 'If specifying other options (--m, --r), --d cannot be blank.'
          break
        elsif datetime.blank? && !msg.nil?
          msg = msg.join(' ')
          if msg.include? ';'
            datetime = msg.split(';', 2)
          else
            datetime = msg.split(' ', 2)
          end
          legacy = true
        end

        datetime = datetime.join(' ')

        rem = ReminderController.new(event, datetime, message, repeat, legacy)
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
