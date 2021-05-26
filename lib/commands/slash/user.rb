# frozen_string_literal: true

module TohsakaBot
  module Slash
    module User
      BOT.application_command(:tool).group(:user) do |group|
        group.subcommand('register') do |event|
          command = CommandLogic::Register.new(event)
          event.respond(content: command.run[:content])
        end

        group.subcommand('set_lang') do |event|
          command = CommandLogic::SetLang.new(event, event.options['lang'])
          event.respond(content: command.run[:content])
        end

        group.subcommand('info') do |event|
          command = CommandLogic::UserInfo.new(event, event.options['user'])
          respond = command.run
          event.respond(content: respond[:content], embeds: respond[:embeds])
        end
      end
    end
  end
end
