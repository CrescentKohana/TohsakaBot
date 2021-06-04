# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Utility
      extend Discordrb::Commands::CommandContainer

      command(:rollprobability,
              aliases: %i[rollchance chanceroll rollp rollc],
              description: 'Returns the probability of getting k hits within n amount of rolls with the chance of p.',
              usage: 'rollprobability <chance in % (float|int)> <rolls (int)> <hits (int, default: 1)>',
              min_args: 2) do |event, chance, rolls, hits|
        command = CommandLogic::RollProbability.new(event, chance, rolls, hits)
        event.respond(command.run[:content])
      end

      extend Discordrb::EventContainer
      command(:getsauce,
              aliases: %i[saucenao sauce rimg],
              description: 'Finds source for the posted image.',
              usage: 'sauce <link (or attachment)>') do |event, url|
        command = CommandLogic::GetSauce.new(event, url)
        response = command.run
        event.respond(response[:content], nil, response[:embeds]&.first)
      end

      command(:quickie,
              aliases: %i[qm],
              description: 'A quick message which is deleted after n seconds.',
              usage: 'quickie <message> <1-10 (seconds, integer, default 5)>',
              min_args: 1) do |event, *msg|
        duration = if Integer(msg[-1], exception: false).nil? || msg.is_a?(String)
                     5
                   else
                     msg.pop.to_i
                   end
        sleep(CommandLogic::Quickie.duration(duration))
        event.message.delete
      end
    end
  end
end
