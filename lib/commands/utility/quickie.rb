module TohsakaBot
  module Commands
    module Quickie
      extend Discordrb::Commands::CommandContainer
      command(:quickie,
              aliases: %i[snapchat sc qm],
              description: 'A quick message which is deleted after n seconds.',
              usage: 'quickie <1-10 (seconds, integer)> <message>',
              min_args: 1) do |event, s, *msg|

        case s.to_i
        when 1..10
          sleep(s.to_i)
          event.message.delete
        else
          sleep(10)
          event.message.delete
        end
      end
    end
  end
end
