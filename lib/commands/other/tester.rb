module TohsakaBot
  module Commands
    module Tester
      extend Discordrb::Commands::CommandContainer
      command(:tester,
              aliases: %i[test t],
              description: 'Test',
              usage: 'test <msg>',
              rescue: "Something went wrong!\n`%exception%`") do |event, url|

        cfg = YAML.load_file('cfg/config.yml')
        BOT.game = cfg['np']
        event.<< url
      end
    end
  end
end
