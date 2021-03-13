module TohsakaBot
  module Commands
    module RoleAdd
      extend Discordrb::Commands::CommandContainer
      command(:roleadd,
              aliases: TohsakaBot.get_command_aliases('commands.management.add_role.aliases'),
              description: I18n.t(:'commands.management.add_role.description'),
              usage: I18n.t(:'commands.management.add_role.usage'),
              enabled_in_pm: false,
              min_args: 1) do |event, *roles|

        added_roles = Set.new
        roles.each do |role|
          next if added_roles.include? role
          next unless CFG.allowed_roles.include? role.to_s

          found_role = event.server.roles.find { |r| r.name == role }
          next if found_role.nil?

          Discordrb::API::Server.add_member_role(
            "Bot #{AUTH.bot_token}",
            event.channel.server.id,
            event.message.user.id,
            found_role.id
          )
          added_roles.add(role)
        end

        if added_roles.empty?
          event.respond(I18n.t(:'commands.management.add_role.errors.not_found'))
        else
          event.respond(I18n.t(:'commands.management.add_role.response', roles: added_roles.join(", ")))
        end
      end
    end
  end
end
