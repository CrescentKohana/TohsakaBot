# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Admin
      extend Discordrb::Commands::CommandContainer

      command(:registerslash,
              aliases: TohsakaBot.get_command_aliases('commands.tool.admin.register_slash.aliases'),
              description: I18n.t(:'commands.tool.admin.register_slash.description'),
              usage: I18n.t(:'commands.tool.admin.register_slash.usage'),
              permission_level: TohsakaBot.permissions.roles["owner"],
              min_args: 1) do |event, *types|
        command = CommandLogic::RegisterSlash.new(event, types)
        event.respond(command.run[:content])
      end

      command(:eval,
              description: I18n.t(:'commands.tool.admin.eval.description'),
              usage: I18n.t(:'commands.tool.admin.eval.usage'),
              help_available: false,
              permission_level: TohsakaBot.permissions.roles["owner"]) do |event|
        # Hard coded to allow ONLY the owner to have access.
        break unless event.user.id == AUTH.owner_id.to_i

        command = CommandLogic::Eval.new(event, event.message.content[5..])
        event.respond(command.run[:content])
      end

      command(:editpermissions,
              aliases: TohsakaBot.get_command_aliases('commands.tool.admin.edit_permissions.aliases'),
              description:  I18n.t(:'commands.tool.admin.edit_permissions.description'),
              usage:  I18n.t(:'commands.tool.admin.edit_permissions.usage'),
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["permissions"]) do |event, user, level|
        command = CommandLogic::EditPermissions.new(event, user, level)
        event.respond(command.run[:content])
      end
    end
  end
end
