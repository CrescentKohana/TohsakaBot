module TohsakaBot
  module Commands
    module ReminderAdd
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: %i[remind reminder remadd remind addrem muistuta muistutus rem],
              description: 'Reminder.',
              usage: 'remindme <R〇y〇M〇w〇d〇h〇m〇s||time as natural language||ISO8601 etc.. (if spaces, use ; after the time)> <msg> (R for repeated, >10 minutes)',
              min_args: 1,
              require_register: true) do |event, time_input, *msg|

        rem = ReminderController.new(event, time_input, msg)
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
