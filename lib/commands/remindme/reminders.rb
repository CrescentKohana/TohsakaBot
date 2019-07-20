module TohsakaBot
  module Commands
    module Reminders
      extend Discordrb::Commands::CommandContainer
      command(:reminders,
              aliases: %i[listrem remlist rems],
              description: 'Lists reminders.',
              usage: 'reminders <id (sort by id, default is by date)>',
              rescue: "Something went wrong!\n`%exception%`") do |event, sort|

        remindb = YAML.load_file('data/reminders.yml')
        active_reminders = []
        output = "```  ID | WHEN                      | MSG (Repeat)\n===================================================\n"
        pos = 0

        sorted = if sort.to_s == 'id'
                   remindb.sort_by { |k| k }
                 else
                   remindb.sort_by { |_, v| v['time'].to_i }
                 end

        sorted.each do |key, value|
          if event.author.id.to_i == value['user'].to_i

            active_reminders << [key, value['message'], value['user'], value['channel'], value['time'], value['repeat']]

            repeat = if active_reminders[pos][5] != 'false'
                       '(R)'
                     else
                       ''
                     end

            if active_reminders[pos][1].empty?

              output << "#{sprintf("%4s", active_reminders[pos][0])} | #{Time.at(active_reminders[pos][4].to_i)} | No message specified #{repeat}\n"
            else
              output << "#{sprintf("%4s", active_reminders[pos][0])} | #{Time.at(active_reminders[pos][4].to_i)} | #{active_reminders[pos][1]} #{repeat}\n"
            end
            pos += 1
          end
        end

        if active_reminders.any?
          "#{output}```"
        else
          event.<< 'No reminders found.'
        end
      end
    end
  end
end