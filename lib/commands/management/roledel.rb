module TohsakaBot
  module Commands
    module RoleDel
      extend Discordrb::Commands::CommandContainer
      command(:roledel,
              aliases: %i[delrole remrole rolerem],
              description: 'Delete a role from the user.',
              usage: 'roledel <role>',
              enabled_in_pm: false,
              min_args: 1) do |event, role|

        if CFG.allowed_roles.include? role.to_s
          found_role = event.server.roles.find { |r| r.name == role }
          if found_role.nil?
            event.respond('The requested role was not found on this server.')
            break
          else
            Discordrb::API::Server.remove_member_role("Bot #{AUTH.bot_token}", event.channel.server.id, event.message.user.id, found_role.id)
            event.respond("Role deleted.")
          end
        else
          event.respond("The role you requested was not found in the list of usabled roles.")
        end
      end
    end
  end
end
