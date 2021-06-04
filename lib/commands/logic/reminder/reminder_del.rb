# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class ReminderDel
      def initialize(event, ids)
        @event = event
        @ids = []

        ids.each do |id|
          if /\d+-\d+/.match(id)
            range = id.split("-").map(&:to_i)
            # Limit range: x..x+(1..100)
            range[1] = range[1].clamp(range[0] + 1, range[0] + 100)
            @ids += (range[0]..range[1]).to_a
          elsif !Integer(id, exception: false).nil?
            @ids << id.to_i
          end
        end
      end

      def run
        return { content: I18n.t(:'commands.reminder.del.errors.no_valid_ids') } if @ids.blank?

        deleted = []
        reminders = TohsakaBot.db[:reminders]
        user_id = TohsakaBot.get_user_id(TohsakaBot.command_event_user_id(@event))

        TohsakaBot.db.transaction do
          @ids.each do |id|
            deleted << id if reminders.where(user_id: user_id, id: id).delete.positive?
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
