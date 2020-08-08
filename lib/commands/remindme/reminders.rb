module TohsakaBot
  module Commands
    module Reminders
      extend ActionView::Helpers::DateHelper
      extend Discordrb::Commands::CommandContainer
      command(:reminders,
              aliases: %i[listrem remlist rems],
              description: 'Lists reminders.',
              usage: 'reminders',
              require_register: true) do |event|

        reminders = TohsakaBot.db[:reminders]
        parsed_reminders = []

        begin
          user_id = TohsakaBot.get_user_id(event.author.id.to_i).to_i
          parsed_reminders = reminders.where(:user_id => user_id).order(:datetime)
        rescue
          #
        end

        output = "```  ID | WHEN                      | MSG (Repeat)\n===================================================\n"

        parsed_reminders.each do |r|
          id = r[:id].to_i
          datetime = r[:datetime]
          msg = r[:message]
          repeat_time = r[:repeat].to_i

          repeat_time = if repeat_time == 0
                          ''
                        else
                          " (#{distance_of_time_in_words(repeat_time)})"
                        end

          if msg.nil?
            output << "#{sprintf("%4s", id)} | #{datetime} | No message specified#{repeat_time}\n"
          else
            output << "#{sprintf("%4s", id)} | #{datetime} | #{msg}#{repeat_time}\n"
          end
        end

        msgs = []
        if parsed_reminders.any?
          msgs << event.respond("#{output}```")
        else
          msgs << event.respond('No reminders found.')
        end

        TohsakaBot.expire_msg(event.channel, msgs, event.message)
        break
      end
    end
  end
end
