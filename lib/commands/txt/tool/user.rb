# frozen_string_literal: true

module TohsakaBot
  module Commands
    module User
      extend Discordrb::Commands::CommandContainer

      command(:register,
              description: I18n.t(:'commands.tool.user.register.description')) do |event|
        command = CommandLogic::Register.new(event)
        event.respond(command.run[:content])
      end

      command(:setlang,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.set_lang.aliases'),
              description: I18n.t(:'commands.tool.user.set_lang.description'),
              usage: I18n.t(:'commands.tool.user.set_lang.usage'),
              min_args: 1,
              require_register: true) do |event, locale|
        command = CommandLogic::SetLang.new(event, locale)
        event.respond(command.run[:content])
      end

      command(:userinfo,
              aliases: TohsakaBot.get_command_aliases('commands.utility.user_info.aliases'),
              description: I18n.t(:'commands.tool.user.info.description'),
              usage: I18n.t(:'commands.tool.user.info.usage')) do |event, user|
        command = CommandLogic::UserInfo.new(event, user)
        response = command.run
        event.respond(response[:content], nil, response[:embeds].first)
      end
    end
  end
end
