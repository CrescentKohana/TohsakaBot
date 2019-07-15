module TohsakaBot
  module Commands
    module Spoiler
      extend Discordrb::Commands::CommandContainer
      command(:spoiler,
              aliases: %i[spoilers rot13 rotta13],
              description: 'ROT13.',
              usage: 'spoilers <for what> <message (1016 characters max)>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|

        event.message.create_reaction('🔓')
      end
    end
  end
end
