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
        unless TohsakaBot.permissions.able?(user_id, "owner", :role)
          return  { content: I18n.t(:'commands.tool.admin.register_slash.error.permission') }
        end

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

        { content: "#{I18n.t(:'commands.tool.admin.register_slash.response')}`#{registered_commands.join('` `')}`" }
      end
    end
  end
end
