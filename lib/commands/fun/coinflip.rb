module TohsakaBot
  module Commands
    module Coinflip
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:coinflip,
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
        # benchmark = event.respond 'Benchmarking...'
        coin = { "Tails:"  => 49, "Heads:" => 49, "The coin landed on its edge:" => 2 }

        pickup = Pickup.new(coin)
        picked = pickup.pick(n.to_i)
        c = picked.uniq.map { |x| [x, picked.count(x)] }.to_h

        if c.any?
          event.<< c.keys[0].to_s + ' ' + c.values[0].to_s + ' ' + c.keys[1].to_s + ' ' + c.values[1].to_s + ' ' + c.keys[2].to_s + ' ' + c.values[2].to_s
        else
          picked = pickup.pick(1)
          # Coinmaster manipulation
          if event.author.id.to_i == 73091459573616640
            picked = 'The coin landed on its edge'
          end

          case picked.chomp(':')
          when 'Tails'
            @result = 'tails'
          when 'Heads'
            @result = 'heads'
          when 'The coin landed on its edge'
            user_id = event.author.id
            server_id = event.channel.server.id
            unless BOT.member(event.server, user_id).role?(519978902425305088)
              Discordrb::API::Server.add_member_role("Bot #{$config['bot_token']}", server_id, user_id, $settings['winner_role'].to_i)
              store = YAML::Store.new('data/temporary_roles.yml')
              store.transaction do
                i = 1
                while store.root?(i) do i += 1 end
                store[i] = {"time" => Time.now, "user" => user_id, "server" => server_id}
                store.commit
              end
            end
          end
          event.respond picked.chomp(':')
          if @result.is_a? String
            event.channel.send_file(File.open("img/#{@result}.png"))
          end
        end
        # benchmark.edit "Benchmark complete. #{Time.now - event.timestamp} seconds."
      end
    end
  end
end
