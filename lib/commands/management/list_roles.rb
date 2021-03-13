# frozen_string_literal: true

module TohsakaBot
  module Commands
    module ListRoles
      extend Discordrb::Commands::CommandContainer
      command(:listroles,
              aliases: %i[roles rolelist],
              description: 'Lists roles.',
              usage: "listroles <'all' or 'server' to list all the roles in this server>",
              enabled_in_pm: false) do |event, filter|
        event << if %w[server all].include?(filter)
                   "Roles of **#{event.server.name}**: \n`#{event.server.roles.map(&:name).join(', ')}`"
                 else
                   "Allowed roles: \n`#{CFG.allowed_roles.join(', ')}`"
                 end
      end
    end
  end
end
