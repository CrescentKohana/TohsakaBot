module TohsakaBot
  module Commands
    module GrandOrder
      extend Discordrb::Commands::CommandContainer
      command(:burnquartz,
              aliases: %i[],
              description: 'Salt.',
              usage: 'yes',
              rescue: "Something went wrong!\n`%exception%`") do |event|

        event.<< 'bye rent money'
      end
    end
  end
end