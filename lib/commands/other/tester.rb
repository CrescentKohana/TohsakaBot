module TohsakaBot
  module Commands
    module Tester
      extend Discordrb::Commands::CommandContainer
      command(:tester,
              aliases: %i[test t],
              description: 'Test',
              usage: 'test <msg>',
              rescue: "Something went wrong!\n`%exception%`") do |event, url|

        event.<< "```huutista```".sanitize_string
      end
    end
  end
end
