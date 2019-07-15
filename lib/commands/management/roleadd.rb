module TohsakaBot
  module Commands
    module RoleAdd
      extend Discordrb::Commands::CommandContainer
      command(:roleadd,
              aliases: %i[addrole],
              description: 'Add a role to the user.',
              usage: 'roladd <role>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, role|

        # dc = Set.new $settings['allowed_roles'].map(&:downcase)

        if $settings['allowed_roles'].include? role.to_s

          found_role = event.server.roles.find { |r| r.name == role }
          Discordrb::API::Server.add_member_role("Bot #{$config['bot_token']}", event.channel.server.id, event.message.user.id, found_role.id)
          event.respond("Role added.")
        else
          event.respond("The role you requested was not found in the list of usabled roles.")
        end
      end
    end
  end
end