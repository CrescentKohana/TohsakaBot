module TohsakaBot
  module Events
    module TriggerEvent
      extend Discordrb::EventContainer
      cd_seconds = 60
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :always_triggers, delay: cd_seconds
      message(containing: TohsakaBot.trigger_data.active_triggers) do |event|

        mentions = event.message.mentions
        sure_trigger = false
        mentions.each { |user| if user.current_bot? then sure_trigger = true end }

        if sure_trigger
          if rate_limiter.rate_limited?(:always_triggers, event.author)
            sure_trigger = false
          end
        end

        unless event.channel.pm?
          TohsakaBot.trigger_data.full_triggers.each do |k, v|
            mode = v["mode"].to_i
            phrase = v["phrase"]
            msg = event.content
            match = false

            if mode == 1
              phrase = '/.*\b' + phrase.to_s + '\b.*/i'
              msg = msg.gsub("<@!#{AUTH.cli_id}>", "").strip
              match = true if (msg =~ phrase.to_regexp(detect: true)) == 0
            elsif mode == 2
              msg = msg.gsub("<@!#{AUTH.cli_id}>", "").strip
              match = true if (msg =~ phrase.to_regexp(detect: true)) == 0
            else
              msg = msg.gsub("<@!#{AUTH.cli_id}>", "").strip
              match = true if msg == phrase.to_s
            end

            if match
              if sure_trigger
                picked = true
              else
                chance = v["chance"].to_i
                c = chance.to_i == 0 || chance.nil? || chance == '0' ? CFG.default_trigger_chance.to_i : chance.to_i
                pickup = Pickup.new({true => c, false => 100 - c})
                picked = pickup.pick(1)
              end

              if picked
                file = v["file"]
                if file.to_s.empty?
                  event.<< v['reply']
                else
                  event.channel.send_file(File.open("triggers/#{file}"))
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
