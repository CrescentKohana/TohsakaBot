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
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.language.aliases'),
              description: I18n.t(:'commands.tool.user.language.description'),
              usage: I18n.t(:'commands.tool.user.language.usage'),
              min_args: 1,
              require_register: true) do |event, locale|
        command = CommandLogic::SetLang.new(event, locale)
        event.message.reply!(command.run[:content])
      end

      command(:birthday,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.birthday.aliases'),
              description: I18n.t(:'commands.tool.user.birthday.description'),
              usage: I18n.t(:'commands.tool.user.birthday.usage'),
              min_args: 1,
              require_register: true) do |event, date, time|
        command = CommandLogic::SetBirthday.new(event, date, time)
        event.message.reply!(command.run[:content])
      end

      command(:userinfo,
              aliases: TohsakaBot.get_command_aliases('commands.tool.user.info.aliases'),
              description: I18n.t(:'commands.tool.user.info.description'),
              usage: I18n.t(:'commands.tool.user.info.usage')) do |event, user|
        id = if event.message.mentions.length > 0
               event.message.mentions[0].id
             elsif !Integer(user, exception: false).nil? && user.to_i.positive?
               user
             end

        command = CommandLogic::UserInfo.new(event, id)
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
