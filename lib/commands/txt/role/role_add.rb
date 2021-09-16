# frozen_string_literal: true

module TohsakaBot
  module Commands
    module RoleAdd
      extend Discordrb::Commands::CommandContainer
      command(:roleadd,
              aliases: TohsakaBot.get_command_aliases('commands.roles.add.aliases'),
              description: I18n.t(:'commands.roles.add.description'),
              usage: I18n.t(:'commands.roles.add.usage'),
              enabled_in_pm: false,
              min_args: 1) do |event, *roles|
        added_roles = Set.new
        roles.each do |role|
          next if added_roles.include? role

          role_id = TohsakaBot.permissions.allowed_role(event.author.id, event.server.id, role)
          next if role_id.nil?

          Discordrb::API::Server.add_member_role(
            "Bot #{AUTH.bot_token}",
            event.channel.server.id,
            event.message.user.id,
            role_id
          )
          added_roles.add(TohsakaBot.role_cache[event.server.id][:roles][role_id][:name])
        end

        if added_roles.empty?
          event.respond(I18n.t(:'commands.roles.errors.role_not_found'))
        else
          event.respond(I18n.t(:'commands.roles.add.response', roles: added_roles.join(", ")))
        end
      end
    end
  end
end
