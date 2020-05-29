module TohsakaBot
  module Commands
    module ReminderEdit
      extend Discordrb::Commands::CommandContainer
      command(:reminderedit,
              aliases: %i[editreminder editrem erem reme],
              description: 'Used to edit a reminder.',
              usage: 'editreminder <id> <R01y01M01w01d01h01m01s||yyyy-MM-dd_hh:mm:ss> <msg>',
              min_args: 2,
              rescue: "Something went wrong!\n`%exception%`") do |event, id, time, *msg|

        remindb = YAML.load_file('data/reminders.yml')
        final_msg = msg.join(' ').strip_mass_mentions.sanitize_string

        remindb.each do |key, value|
            if event.author.id.to_i == value["user"].to_i && key.to_i == id.to_i

              orig_data = [value["time"], value["msg"], value["user"], value["channel"], value["repeat"]]

              rstore = YAML::Store.new('data/reminders.yml')
              rstore.transaction do
                rstore.delete(key)
                rstore[key] = {
                    "time"    => time.seconds + rep.to_i,
                    "message" => msg.to_s,
                    "user"    => orig_data[2].to_s,
                    "channel" =>orig_data[3].to_s,
                    "repeat"  => ""
                }
                rstore.commit
              end
              @check = 1
              next
            end
        end

        if defined? @check
          event.<< 'Reminder edited.'
        else
          event.<< 'The ID was not found within your list of triggers.'
        end
      end
    end
  end
end
