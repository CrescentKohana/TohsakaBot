module TohsakaBot
  module Commands
    module MessagePrune
      extend Discordrb::Commands::CommandContainer
      command(:prune,
              description: 'Prunes betweem 2 and 100 messages in the current channel.',
              usage: 'prune <amount (2-100)>',
              permission_level: 1000) do |event, amount|

        if /\A\d+\z/.match(amount) && (2..100).include?(amount.to_i)
          event.channel.prune(amount.to_i)
          break
        else
          event.respond('The amount of messages has to be between 2 and 100.')
        end
      end
    end
  end
end
