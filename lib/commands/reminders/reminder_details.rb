module TohsakaBot
  module Commands
    module ReminderDetails
      extend Discordrb::Commands::CommandContainer
      command(:reminderdetails,
              aliases: %i[reminderdetail reminderinfo inforeminder rinfo],
              description: 'Shows details about reminders.',
              usage: "Use 'reminderdetails <id> <verbose>",
              min_args: 1,
              require_register: true) do |event, id, verbose|

        verbose = verbose.nil? ? false : true
        unless Integer(id, exception: false).nil?
          user_id = TohsakaBot.get_user_id(event.author.id.to_i).to_i
          reminder = TohsakaBot.db[:reminders].where(id: id.to_i, user_id: user_id).single_record!
          unless reminder.nil?
            channel = BOT.channel(reminder[:channel].to_i)
            channel = channel.nil? ? "" : "Channel: #{channel.name}"
            repeat_time = if reminder[:repeat].zero?
                            ""
                          else
                            "#{distance_of_time_in_words(reminder[:repeat])}"
                          end

            event.channel.send_embed do |e|
              e.colour = 0xA82727
              e.add_field(name: "When <ID: #{id}>", value: "#{reminder[:datetime]}")
              unless reminder[:message].nil? || reminder[:message].empty?
                e.add_field(name: 'Message', value: reminder[:message].to_s)
              end
              e.add_field(name: 'Repeat', value: repeat_time) unless repeat_time.empty?
              e.add_field(name: 'Created At', value: reminder[:created_at].to_s) if verbose
              e.add_field(name: 'Updated At', value: reminder[:updated_at].to_s) if verbose
              e.footer = Discordrb::Webhooks::EmbedFooter.new(text: channel)
            end
            break
          end
        end

        event.respond("Specified reminder wasn't found.")
      end
    end
  end
end
