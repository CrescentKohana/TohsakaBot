# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Fun
      extend Discordrb::Commands::CommandContainer

      # Ratelimit for users. 15 times in a span of 60 seconds (1s delay between each).
      # TODO: Maybe move these to a single file across all commands?
      bucket :cf, limit: 15, time_span: 60, delay: 1

      command(:number,
              aliases: TohsakaBot.get_command_aliases('commands.fun.number.aliases'),
              description: I18n.t(:'commands.fun.number.description'),
              usage: I18n.t(:'commands.fun.number.usage'),
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, one, two|
        command = CommandLogic::Number.new(event, one, two)
        event.respond(command.run[:content])
      end

      command(:coinflip,
              aliases: TohsakaBot.get_command_aliases('commands.fun.coinflip.aliases'),
              description: I18n.t(:'commands.fun.coinflip.description'),
              usage: I18n.t(:'commands.fun.coinflip.usage'),
              bucket: :cf,
              rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, times|
        command = CommandLogic::Coinflip.new(event, times)
        response = command.run
        event.respond(response[:content], nil, response[:embeds]&.first)
      end

      command(:fgo,
              aliases: TohsakaBot.get_command_aliases('commands.fun.fgo.aliases'),
              description: I18n.t(:'commands.fun.fgo.description'),
              usage: I18n.t(:'commands.fun.fgo.usage')) do |event, amount, currency, verbose|
        command = CommandLogic::FGO.new(event, amount, currency, verbose)
        response = command.run
        event.respond(response[:content], nil, response[:embeds]&.first)
      end

      command(:chaos,
              aliases: TohsakaBot.get_command_aliases('commands.fun.chaos.aliases'),
              description: I18n.t(:'commands.fun.chaos.description'),
              usage: I18n.t(:'commands.fun.chaos.usage'),
              min_args: 1) do |event, *txt|
        command = CommandLogic::Chaos.new(event, txt)
        event.respond(command.run[:content])
      end
    end
  end
end
