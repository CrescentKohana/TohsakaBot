module TohsakaBot
  module Commands
    module RoleDel
      extend Discordrb::Commands::CommandContainer
      command(:roledel,
              aliases: TohsakaBot.get_command_aliases('commands.management.del_role.aliases'),
              description: I18n.t(:'commands.management.del_role.description'),
              usage: I18n.t(:'commands.management.del_role.usage'),
              enabled_in_pm: false,
              min_args: 1) do |event, *roles|

        deleted_roles = Set.new
        roles.each do |role|
          next if deleted_roles.include? role
          next unless CFG.allowed_roles.include? role.to_s

          found_role = event.server.roles.find { |r| r.name == role }
          next if found_role.nil?

          Discordrb::API::Server.remove_member_role(
            "Bot #{AUTH.bot_token}",
            event.channel.server.id,
            event.message.user.id,
            found_role.id
          )
          deleted_roles.add(role)
        end

        if deleted_roles.empty?
          event.respond(I18n.t(:'commands.management.del_role.errors.not_found'))
        else
          event.respond(I18n.t(:'commands.management.del_role.response', roles: deleted_roles.join(", ")))
        end
      end
    end
  end
end
