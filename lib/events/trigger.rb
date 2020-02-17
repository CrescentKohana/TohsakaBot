module TohsakaBot
  module Events
    module Trigger
      extend Discordrb::EventContainer
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :always_triggers, delay: 90, rate_limit_message: '100% triggers on this channel are on a %time% second ratelimitation.'
      message(containing: $triggers_only) do |event|
        break if event.channel.pm?

        # TODO: Iterate more because of overlapping!
        $triggers = YAML.load_file('data/triggers.yml')
        $triggers.each do |k, v|
          mode = v["mode"].to_i
          phrase = v["phrase"]
          msg = event.content
          match = false
          if mode == 1
            phrase = '/.*\b' + phrase.to_s + '\b.*/i'
            match = true if (msg =~ phrase.to_regexp(detect: true)) == 0
          elsif mode == 2
            msg = msg.gsub("<@!#{$config["cli_id"]}>", "").strip
            match = true if (msg =~ phrase.to_regexp(detect: true)) == 0
          else
            msg = msg.gsub("<@!#{$config["cli_id"]}>", "").strip
            match = true if msg == phrase.to_s
          end

          if match
            if event.content.include?("<@!#{$config["cli_id"]}>") && !rate_limiter.rate_limited?(:always_triggers, event.channel)
              picked = true
            elsif event.content.include?("<@!#{$config["cli_id"]}>")
              picked = false
              # TODO: Show realtime cooldown
              # event.<< 'Calm down! 100% triggers have a 90s ratelimitation per channel.'
            else
              chance = v["chance"].to_i
              c = chance.to_i == 0 || chance.nil? || chance == '0' ? $settings['default_trigger_chance'].to_i : chance.to_i
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
