# frozen_string_literal: true

module TohsakaBot
  module Commands
    module User
      extend Discordrb::Commands::CommandContainer

      command(:register,
              description: I18n.t(:'commands.tool.user.register.description')) do |event|
        command = CommandLogic::Register.new(event)
        event.message.reply!(command.run[:content])
      end

      command(:setlang,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.set_lang.aliases'),
              description: I18n.t(:'commands.tool.user.set_lang.description'),
              usage: I18n.t(:'commands.tool.user.set_lang.usage'),
              min_args: 1,
              require_register: true) do |event, locale|
        command = CommandLogic::SetLang.new(event, locale)
        event.message.reply!(command.run[:content])
      end

      command(:setbirthday,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.set_birthday.aliases'),
              description: I18n.t(:'commands.tool.user.set_birthday.description'),
              usage: I18n.t(:'commands.tool.user.set_birthday.usage'),
              min_args: 1,
              require_register: true) do |event, date|
        command = CommandLogic::SetBirthday.new(event, date)
        event.message.reply!(command.run[:content])
      end

      command(:userinfo,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.user_info.aliases'),
              description: I18n.t(:'commands.tool.user.info.description'),
              usage: I18n.t(:'commands.tool.user.info.usage')) do |event, user|
        command = CommandLogic::UserInfo.new(event, user)
        response = command.run
        event.respond(response[:content], nil, response[:embeds].first)
      end

      command(:privateprune,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.private_prune.aliases'),
              description: I18n.t(:'commands.tool.user.private_prune.description'),
              usage: I18n.t(:'commands.tool.user.private_prune.usage'),
              min_args: 1) do |event, amount|
        command = CommandLogic::PrivatePrune.new(event, amount)
        response = command.run
        m = event.respond(response[:content])
        sleep(10)
        m.delete
        # Delete the command invocation too unless in pm
        event.message.delete unless event.channel.pm?
      end
    end
  end
end
