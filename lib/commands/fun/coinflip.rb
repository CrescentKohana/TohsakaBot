module TohsakaBot
  module Commands
    module Coinflip
      extend Discordrb::Commands::CommandContainer

      # Ratelimit for users. 15 times in a span of 60 seconds (1s delay between each).
      # TODO: Maybe move these to a single file across all commands?
      bucket :cf, limit: 15, time_span: 60, delay: 1

      command(:coinflip,
              # TODO: Move all command aliases to a single file.
              aliases: %i[coin flip toss kolike kolikko heitähomovoltti flop kkoin],
              description: 'Flip a coin.',
              usage: 'flip <integer>',
              bucket: :cf,
              rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event, n|

        # Let's try to keep the CPU intact while we're at it.
        if n.to_i > 100000
          event.<< 'Sorry but the limit is 100000.'
          break
        end

        # Probabilities for the coin toss (%).
        coin = { "Tails:"  => 49, "Heads:" => 49, "The coin landed on its edge:" => 2 }
        coin_toss = Pickup.new(coin)

        if n.to_i > 1
          c = coin_toss.pick(n.to_i).uniq.map { |x| [x, coin_toss.count(x)] }.to_h
          event.<< c.keys[0].to_s + ' ' + c.values[0].to_s + ' ' + c.keys[1].to_s + ' ' + c.values[1].to_s + ' ' + c.keys[2].to_s + ' ' + c.values[2].to_s
        else
          picked = coin_toss.pick(1)

          # Coinmaster manipulation (don't ask)
          if event.author.id.to_i == 73091459573616640
            picked = 'The coin landed on its edge'
          end

          case picked.chomp(':')
          when 'Tails'
            @result = 'tails'
          when 'Heads'
            @result = 'heads'
          when 'The coin landed on its edge'
            Kernel.give_temporary_role(event, $settings['winner_role'])
          end

          event.respond(picked.chomp(':'))
          if @result.is_a? String
            event.channel.send_file(File.open("img/#{@result}.png"))
          end
        end
      end
    end
  end
end
