module TohsakaBot
  module Commands
    module ListRoles
      extend Discordrb::Commands::CommandContainer
      command(:listroles,
              aliases: %i[roles rolelist],
              description: 'Lists roles.',
              usage: "listroles <'all' or 'server' to list all the roles in this server>",
              enabled_in_pm: false) do |event, filter|

        if filter == 'server' || filter == 'all'
          event.<< "Roles of **#{event.server.name}**: \n`#{event.server.roles.map { |role| role.name }.join(", ")}`"
        else
          event.<< "Allowed roles: \n`#{CFG.allowed_roles.join(', ')}`"
        end
      end
    end
  end
end
