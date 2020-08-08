module TohsakaBot
  module Commands
    module RoleAdd
      extend Discordrb::Commands::CommandContainer
      command(:roleadd,
              aliases: %i[addrole],
              description: 'Add a role to the user.',
              usage: 'roladd <role>', # <days (all,wdays,wend,mo,tu,we,th,fr,sa,su)> <start-end (15:00-18:00)>
              min_args: 1) do |event, role|

        if CFG.allowed_roles.include? role.to_s
          found_role = event.server.roles.find { |r| r.name == role }
          Discordrb::API::Server.add_member_role("Bot #{AUTH.bot_token}", event.channel.server.id, event.message.user.id, found_role.id)
          event.respond("Role added.")
        else
          event.respond("The role you requested was not found in the list of usabled roles.")
        end
      end
    end
  end
end
