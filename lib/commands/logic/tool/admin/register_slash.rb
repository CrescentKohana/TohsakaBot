# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class RegisterSlash
      require_relative '../../../../slash_commands'

      def initialize(event, types)
        @event = event
        @types = types
      end

      def run
        user_id = TohsakaBot.command_event_user_id(@event)
        return unless TohsakaBot.permissions.permission?(user_id, TohsakaBot.permissions.roles["owner"])

        slash = SlashCommands.new
        registered_commands = Set.new

        @types.each do |type|
          next if registered_commands.include?(type)

          begin
            slash.send(type)
          rescue NoMethodError
            next
          end
          registered_commands.add(type)
        end

        { content: "Registered top-level commands: `#{registered_commands.join('` `')}`" }
      end
    end
  end
end
