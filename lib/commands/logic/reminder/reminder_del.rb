# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class ReminderDel
      def initialize(event, ids)
        @event = event
        @ids = ids
      end

      def run
        deleted = []
        reminders = TohsakaBot.db[:reminders]
        user_id = TohsakaBot.get_user_id(TohsakaBot.command_event_user_id(@event))

        TohsakaBot.db.transaction do
          @ids.each do |id|
            deleted << id if reminders.where(user_id: user_id, id: id.to_i).delete.positive?
          end
        end

        if deleted.size.positive?
          { content: I18n.t(:'commands.reminder.del.response',
                            plural: @ids.length > 1 ? "s" : "",
                            ids: deleted.join(', ')) }
        else
          { content: I18n.t(:'commands.reminder.del.errors.not_found') }
        end
      end
    end
  end
end
