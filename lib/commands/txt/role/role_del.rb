# frozen_string_literal: true

module TohsakaBot
  module Commands
    module RoleDel
      extend Discordrb::Commands::CommandContainer
      command(:roledel,
              aliases: TohsakaBot.get_command_aliases('commands.roles.del.aliases'),
              description: I18n.t(:'commands.roles.del.description'),
              usage: I18n.t(:'commands.roles.del.usage'),
              enabled_in_pm: false,
              min_args: 1) do |event, *roles|

        deleted_roles = Set.new
        roles.each do |role|
          next if deleted_roles.include? role

          role_id = TohsakaBot.permissions.allowed_role(event.author.id, event.server.id, role)
          next if role_id.nil?

          Discordrb::API::Server.remove_member_role(
            "Bot #{AUTH.bot_token}",
            event.channel.server.id,
            event.message.user.id,
            role_id
          )
          deleted_roles.add(TohsakaBot.server_cache[event.server.id][:roles][role_id][:name])
        end
        if deleted_roles.empty?
          event.respond(I18n.t(:'commands.roles.errors.role_not_found'))
        else
          event.respond(I18n.t(:'commands.roles.del.response', roles: deleted_roles.join(", ")))
        end
      end
    end
  end
end
