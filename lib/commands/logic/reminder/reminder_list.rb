# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class ReminderList
      include ActionView::Helpers::DateHelper
      def initialize(event)
        @event = event
      end

      def run
        reminders = TohsakaBot.db[:reminders]
        parsed_reminders = []

        begin
          user_id = TohsakaBot.get_user_id(TohsakaBot.command_event_user_id(@event))
          parsed_reminders = reminders.where(user_id: user_id).order(:datetime)
        rescue StandardError
          # Ignored
        end

        output = "```  ID | WHEN                      | MSG (Repeat)" \
                 "\n===================================================\n".dup

        parsed_reminders.each do |r|
          id = r[:id].to_i
          datetime = r[:datetime]
          msg = r[:message]
          repeat_time = r[:repeat].to_i

          repeat_time = if repeat_time.zero?
                          ''
                        else
                          " (#{distance_of_time_in_words(repeat_time)})"
                        end

          output << if msg.nil?
                      "#{format('%4s', id)} | #{datetime} | No message specified#{repeat_time}\n"
                    else
                      "#{format('%4s', id)} | #{datetime} | #{msg}#{repeat_time}\n"
                    end
        end

        if parsed_reminders.any?
          { content: "#{output}```" }
        else
          { content: "No reminders found." }
        end
      end
    end
  end
end
