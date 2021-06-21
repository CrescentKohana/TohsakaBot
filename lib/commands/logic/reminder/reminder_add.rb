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

       { content: rem.store_reminder, embeds: nil, error: false }
      end
    end
  end
end

