module TohsakaBot
  module Commands
    module Tester
      extend Discordrb::Commands::CommandContainer
      command(:tester,
              aliases: %i[test t],
              description: 'Test',
              usage: 'test <msg>') do |event|

        event.<< '```huutista```'.sanitize_string
      end
    end
  end
end
