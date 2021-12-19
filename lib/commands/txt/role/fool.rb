# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Fool
      extend Discordrb::Commands::CommandContainer
      command(:fool,
              description: 'Gives user a temporary role of fool.',
              usage: 'fool <user> <duration in days> <reason>',
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["trophy_roles"]) do |event, _user, days, *reason|
        if event.message.mentions.empty?
          event.respond("No user mention defined.")
          break
        end

        user_id = event.message.mentions[0].id.to_i
        TohsakaBot.give_trophy(event, false, user_id, days, reason)
        event.respond(
          "#{event.message.mentions[0].username} has been given the rank of Fool for #{days} day#{'s' if days.to_i > 1}."
        )
      end
    end
  end
end
