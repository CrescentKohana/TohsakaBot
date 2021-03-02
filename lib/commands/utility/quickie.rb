module TohsakaBot
  module Commands
    module Quickie
      extend Discordrb::Commands::CommandContainer
      command(:quickie,
              aliases: %i[snapchat sc qm],
              description: 'A quick message which is deleted after n seconds.',
              usage: 'quickie <1-10 (seconds, integer, default 5)> <message>') do |event, s, *_msg|

        if (1..10).include? s.to_i
          sleep(s.to_i)
        else
          sleep(5)
        end
        event.message.delete
      end
    end
  end
end
