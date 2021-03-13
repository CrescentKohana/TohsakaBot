# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Tester
      extend Discordrb::Commands::CommandContainer
      command(:tester,
              aliases: %i[test t],
              description: 'Command for testing stuff',
              usage: 'test') do |event|
        event.<< "#{Time.now.to_i} <= #{event.message.timestamp.to_i + 3600}"
      end
    end
  end
end
