module TohsakaBot
  module Commands
    module RoleDel
      extend Discordrb::Commands::CommandContainer
      command(:roledel,
              aliases: %i[delrole remrole rolerem derole],
              description: 'Delete a role from the user.',
              usage: 'roledel <role>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, role|

        if CFG.allowed_roles.include? role.to_s
          found_role = event.server.roles.find { |r| r.name == role }
          Discordrb::API::Server.remove_member_role("Bot #{CFG.bot_token}", event.channel.server.id, event.message.user.id, found_role.id)
          event.respond("Role deleted.")
        else
          event.respond("The role you requested was not found in the list of usabled roles.")
        end
      end
    end
  end
end
