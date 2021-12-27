# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Fun
      BOT.application_command(:fun).subcommand('number') do |event|
        command = CommandLogic::Number.new(event, event.options['start'], event.options['end'])
        event.respond(content: command.run[:content])
      end

      BOT.application_command(:fun).subcommand('coinflip') do |event|
        command = CommandLogic::Coinflip.new(event, event.options['times'])
        response = command.run
        event.respond(content: response[:content], embeds: response[:embeds])
      end

      BOT.application_command(:fun).subcommand('fgo') do |event|
        command = CommandLogic::FGO.new(
          event,
          event.options['amount'],
          event.options['currency'],
          event.options['verbose']
        )
        response = command.run
        event.respond(content: response[:content], embeds: response[:embeds])
      end

      BOT.application_command(:fun).subcommand('chaos') do |event|
        command = CommandLogic::Chaos.new(event, event.options['txt'])
        event.respond(content: command.run[:content], allowed_mentions: false)
      end

      BOT.application_command(:fun).subcommand('martus') do |event|
        command = CommandLogic::Martus.new(event, event.options['txt'])
        event.respond(content: command.run[:content], allowed_mentions: false)
      end
    end
  end
end
