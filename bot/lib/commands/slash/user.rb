# frozen_string_literal: true

module TohsakaBot
  module Slash
    module User
      BOT.application_command(:tool).group(:user) do |group|
        group.subcommand('register') do |event|
          command = CommandLogic::Register.new(event)
          event.respond(content: command.run[:content])
        end

        group.subcommand('language') do |event|
          command = CommandLogic::SetLang.new(event, event.options['lang'])
          event.respond(content: command.run[:content], ephemeral: true)
        end

        group.subcommand('timezone') do |event|
          command = CommandLogic::SetTimezone.new(event, event.options['tz'])
          event.respond(content: command.run[:content], ephemeral: true)
        end

        group.subcommand('birthday') do |event|
          command = CommandLogic::SetBirthday.new(
            event,
            "#{event.options['year']}-#{event.options['month']}-#{event.options['day']}",
            "#{event.options['hour']}:#{event.options['minute']}:00"
          )
          event.respond(content: command.run[:content], ephemeral: true)
        end

        group.subcommand('info') do |event|
          command = CommandLogic::UserInfo.new(event, event.options['user'])
          respond = command.run
          event.respond(content: respond[:content], embeds: respond[:embeds], ephemeral: event.options['ephemeral'])
        end
      end
    end
  end
end
