module TohsakaBot
  module Commands
    module ReminderDel
      extend Discordrb::Commands::CommandContainer
      command(:reminderdel,
              aliases: %i[delreminder dontremindme remrem remdel delrem remremind delremind],
              description: 'Deletes an active reminder.',
              usage: 'delreminder <ids separeted by space (integer)>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *ids|

        remindb = YAML.load_file('data/reminders.yml')
        i = 0

        remindb.each do |key, value|
          ids.each do |x|

            if event.author.id.to_i == value["user"].to_i && key.to_i == x.to_i
              i += 1
              rstore = YAML::Store.new('data/reminders.yml')

              rstore.transaction do
                rstore.delete(key)
                rstore.commit
              end

              @check = 1
              next
            end
          end
        end

        if defined? @check
          event.<< 'Reminder(s) deleted.'
        else
          event.<< 'One or more IDs were not found within your list of triggers.'
        end
      end
    end
  end
end