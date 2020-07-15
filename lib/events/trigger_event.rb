module TohsakaBot
  module Events
    module TriggerEvent
      extend Discordrb::EventContainer
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new

      message(containing: TohsakaBot.trigger_data.active_triggers) do |event|
        mentions = event.message.mentions
        sure_trigger = false
        mentions.each { |user| if user.current_bot? then sure_trigger = true end }

        if sure_trigger
          rate_limiter.bucket :sure_triggers, delay: 60
          sure_trigger = false if rate_limiter.rate_limited?(:sure_triggers, event.author)
        end

        unless event.channel.pm?
          triggers = TohsakaBot.db[:triggers]
          server_triggers = triggers.where(:server_id => event.server.id.to_i)
          per_msg_limit = 0

          server_triggers.each do |t|
            phrase = t[:phrase]
            mode = t[:mode].to_i
            msg = event.content.gsub("<@!#{AUTH.cli_id}>", "").strip
            match = false

            if mode == 1
              phrase = /.*\b#{phrase}\b.*/i
            elsif mode != 2
              phrase = /^#{phrase}/i
            end

            regex = Regexp.new phrase

            match = true if regex.match?(msg)

            if match
              # Max two triggers per message
              per_msg_limit += 1
              break if per_msg_limit > 2

              if sure_trigger
                picked = true
              else
                chance = t[:chance].to_i
                default_chance = CFG.default_trigger_chance.to_i
                c = chance == 0 ? default_chance : chance

                # Three times the default chance if Exact mode.
                c *= 3 if chance == default_chance && mode == 0

                pickup = Pickup.new({true => c, false => 100 - c})
                picked = pickup.pick(1)
              end

              if picked
                file = t[:file]
                if file.to_s.empty?
                  event.<< t[:reply]
                else
                  event.channel.send_file(File.open("data/triggers/#{file}"))
                end
              else
                break
              end
            end
          end
        end
      end
    end
  end
end
