# frozen_string_literal: true

module TohsakaBot
  module Commands
    module MVP
      extend Discordrb::Commands::CommandContainer
      command(:mvp,
              aliases: %i[lord winner],
              description: 'Gives user a temporary role of MVP.',
              usage: 'mvp <user> <duration in days> <reason>',
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["trophy_roles"]) do |event, _user, days, *reason|
        user_id = event.message.mentions[0].id

        TohsakaBot.give_temporary_role(event, CFG.mvp_role, user_id, days, reason)
        event.respond(
          "#{event.message.mentions[0].username} has been decided to be a MVP for #{days} day#{'s' if days.to_i > 1}."
        )
      end
    end
  end
end
