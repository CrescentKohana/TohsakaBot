# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class ReminderMod
      def initialize(event, id, datetime, msg, repeat, channel)
        @event = event
        @discord_uid = TohsakaBot.command_event_user_id(@event)
        @id = id
        @datetime = datetime
        @msg = msg
        @repeat = repeat
        @channel = if channel.nil?
                     nil
                   else
                     channel.is_a?(Discordrb::Channel) ? channel.id : channel.to_i
                   end
      end

      def run
        return { content: "Specify a reminder ID to edit" } if @id.nil?
        return { content: "Specify an action" } if @datetime.nil? && @msg.nil? && @repeat.nil? && @channel.nil?

        reminders = TohsakaBot.db[:reminders]
        reminder = reminders.where(id: @id.to_i).single_record!

        return { content: "Could not find reminder with that ID" } if reminder.nil?
        return { content: "No permissions to edit this reminder" } if reminder[:user_id] != TohsakaBot.get_user_id(@discord_uid)

        authorized_channels = TohsakaBot.allowed_channels(@discord_uid).map(&:id)
        channel = @channel.nil? || !authorized_channels.include?(@channel) ? nil : @channel.to_i

        rem = ReminderController.new(@event, @id, false, @datetime, @msg, @repeat, channel)

        begin
          ReminderHandler.handle_user_limit(@discord_uid)
        rescue ReminderHandler::UserLimitReachedError => e
          return { content: e.message }
        end

        begin
          rem.convert_datetime
          rem.enforce_repeat_limits
        rescue ReminderHandler::DatetimeError, ReminderHandler::RepeatIntervalError => e
          return { content: e.message }
        end

        response = rem.update_reminder
        button = Discordrb::Components::View.new do |v|
          v.row do |r|
            r.button(style: :primary, label: '🔔', custom_id: "reminder_mod:#{response[:id]}")
          end
        end

        { content: response[:content], components: button }
      end
    end
  end
end
