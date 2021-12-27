# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class ReminderAdd
      def initialize(event, datetime, msg, repeat, legacy_input = nil)
        @event = event
        @datetime = datetime
        @msg = msg
        @repeat = repeat
        @legacy_input = legacy_input.nil? ? nil : legacy_input.join(' ')
      end

      def run
        if @datetime.blank? && (!@msg.blank? || !@repeat.blank?)
          return { content: I18n.t(:'commands.reminder.add.errors.all_blank'), embeds: nil, error: true }
        end

        # Legacy logic for simple reminders through text commands
        legacy = false
        if @datetime.blank? && !@legacy_input.blank?
          @datetime = if @legacy_input.include? ';'
                        @legacy_input.split(';', 2)
                      elsif @legacy_input.include? ' '
                        @legacy_input.split(' ', 2)
                      else
                        [@legacy_input, '']
                      end
          legacy = true
        end

        @datetime = @datetime.join(' ') unless legacy || @datetime.is_a?(String)
        rem = ReminderController.new(@event, nil, legacy, @datetime, @msg, @repeat, @event.channel.id)

        begin
          ReminderHandler.handle_user_limit(TohsakaBot.command_event_user_id(@event))
        rescue ReminderHandler::UserLimitReachedError => e
          return { content: e.message, embeds: nil, error: true }
        end

        begin
          rem.convert_datetime
        rescue ReminderHandler::DatetimeError, ReminderHandler::RepeatIntervalError => e
          return { content: e.message, embeds: nil, error: true }
        end

        response = rem.store_reminder
        button = Discordrb::Components::View.new do |v|
          v.row do |r|
            r.button(style: :primary, label: '🔔', custom_id: "reminder_add:#{response[:id]}")
          end
        end

        { content: response[:content], embeds: nil, components: button, error: false }
      end
    end
  end
end

