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
        if %w[server all].include?(filter)
          event.<< "Roles of **#{event.server.name}**: \n`#{event.server.roles.map(&:name).join(', ')}`"
        else
          roles = TohsakaBot.server_cache[event.server.id][:roles]
          response = "Allowed roles: \n".dup
          roles.each do |_id, role|
            response << "`#{role[:name]}` "
          end
          event.<< response
        end
      end
    end
  end
end
