module TohsakaBot
  module Commands
    module Tester
      extend Discordrb::Commands::CommandContainer
      command(:tester,
              aliases: %i[test t],
              description: 'Test',
              usage: 'test <msg>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|


        event.<< msg.join(' ').strip_mass_mentions.sanitize_string.hide_link_preview
      end
    end
  end
end