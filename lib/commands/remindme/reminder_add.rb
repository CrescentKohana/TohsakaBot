module TohsakaBot
  module Commands
    module ReminderAdd
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: %i[remind reminder remadd remind addrem muistuta muistutus rem],
              description: 'Reminder.',
              min_args: 1,
              usage: 'remindme <R〇y〇M〇w〇d〇h〇m〇s||time as natural language||ISO8601 etc.. (if spaces, use ; after the time)> <msg> (R for repeated, >10 minutes)',
              rescue: "Something went wrong!\n`%exception%`") do |event, time_input, *msg|

        rem = RemindmeCore.new(event, time_input, msg)
        output = rem.convert_datetime
        m = 'Usage: `remindme <R〇y〇M〇w〇d〇h〇m〇s||time as natural language||ISO8601 etc.. (if spaces, use ; after the time)> <msg> (R for repeated, >10 minutes)`'

        if user_limit_reached?("data/reminders.yml", CFG.reminder_limit, event.message.user.id)
          # user_limit_reached?("#{CFG.bot.data}/reminders.yml", CFG.bot.max_reminders, event.user.id)
          m = "Sorry, but the the limit for remainders per user is #{CFG.remainder_limit}! " +
              "Wait that they expire or remove them with `reminders` & `delreminder <id(s)>`."
          output = 0
        end

        case output
        when 1 # Success!
          rem.store_reminder
        when 2 # Past value (or exactly now)
          m = 'The thing is.. time travel is still a little hard for me :(, so try not to use past dates. ' + m
        when 3 # Wrong syntax (or negative values)
          m = 'Wrong syntax or negative values used. ' + m
        when 4 # Limitation of a Gem
          m = 'Mixing weeks with other date parts (y, M, d) is not allowed.'
        when 5 # So no spam
          m = 'The interval limit for repeated reminders is ten minutes. Reminder aborted.'
        else
          m = ''
        end
        event.respond m unless output == 1
      end
    end
  end
end
