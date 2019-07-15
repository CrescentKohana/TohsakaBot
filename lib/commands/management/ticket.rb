module TohsakaBot
  module Commands
    module Triggers
      extend Discordrb::Commands::CommandContainer
      command(:ticket,
              aliases: %i[],
              description: 'Sends a ticket to admins & moderators.',
              usage: '',
              rescue: "Something went wrong!\n`%exception%`") do |event, cat|

        tickets = []
        case cat.to_s
        when 'bot' || 'b'
          puts 1
        when 'report' || 'r'
          puts 2
        else
          puts 3
        end


      end
    end
  end
end