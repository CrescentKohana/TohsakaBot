module TohsakaBot
  module Events
    module TriggerEvent
      extend Discordrb::EventContainer
      # rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      # cd_seconds = 90
      # rate_limiter.bucket :always_triggers, delay: cd_seconds
      # rate_limit_message: '100% triggers on this channel are on a %time% second ratelimitation.'
      message(containing: TohsakaBot.trigger_data.active_triggers) do |event|
        break if event.channel.pm?

        # TODO: Iterate more because of overlapping!
        TohsakaBot.trigger_data.full_triggers.each do |k, v|
          mode = v["mode"].to_i
          phrase = v["phrase"]
          msg = event.content
          match, sure_trigger = false, false
          mentions = event.message.mentions
          mentions.each { |user| if user.current_bot? then sure_trigger = true end }
          
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
            if sure_trigger #&& !rate_limiter.rate_limited?(:always_triggers, event.author)
              picked = true
              # cooldown_time = Time.now.to_i
            elsif event.content.include?("<@!#{AUTH.cli_id}>")
              picked = false
              # TODO: Show realtime cooldown
              # event.<< "Calm down! 100% triggers have a ratelimitation per channel."
            else
              chance = v["chance"].to_i
              c = chance.to_i == 0 || chance.nil? || chance == '0' ? CFG.default_trigger_chance.to_i : chance.to_i
              pickup = Pickup.new({true => c, false => 100 - c})
              picked = pickup.pick(1)
            end

            if picked
              file = v["file"]
              if file.to_s.empty?
                event.respond v['reply']
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
