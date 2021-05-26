# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Eval
      def initialize(event, code)
        @event = event
        @code = code
      end

      def run
        # Hard coded to allow ONLY the owner to have access.
        user_id = TohsakaBot.command_event_user_id(@event)
        return unless user_id == AUTH.owner_id.to_i
        return unless TohsakaBot.permissions.permission?(user_id, TohsakaBot.permissions.roles["owner"])

        begin
          response = eval @code
        rescue StandardError => e
          response = "An error occurred 😞 ```#{e}```"
        end
        response = "_" if response.blank?

        { content: response }
      end
    end
  end
end
