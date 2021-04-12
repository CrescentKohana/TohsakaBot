# frozen_string_literal: true

module TohsakaBot
  module Events
    module TriggerEvent
      extend Discordrb::EventContainer
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new

      message do |event|
        # Private Message channels disabled
        next if event.channel.pm?

        # Strip spoilers: ||spoiler||
        content = event.content.gsub(/(\|\|)(?:(?=(\\?))\2.)*?\1/, '')
        next if Regexp.union(TohsakaBot.trigger_data.trigger_phrases) == content

        # Posts the trigger at 100% probability if bot is also mentioned in the message.
        sure_trigger = false
        mentions = event.message.mentions
        mentions.each { |user| sure_trigger = true if user.current_bot? }

        if sure_trigger
          rate_limiter.bucket :sure_triggers, delay: 60
          sure_trigger = false if rate_limiter.rate_limited?(:sure_triggers, event.author)
        end

        server_triggers = TohsakaBot.trigger_data.triggers.where(server_id: event.server.id.to_i)
        matching_triggers = []

        server_triggers.each do |t|
          phrase = t[:phrase]
          mode = t[:mode].to_i
          msg = content.gsub("<@!#{AUTH.cli_id}>", '').strip

          if mode.zero?
            phrase = /^#{Regexp.quote(phrase)}$/i
            regex = Regexp.new phrase
          elsif mode == 1
            phrase = /.*\b#{phrase}\b.*/i
            regex = Regexp.new phrase
          else
            regex = if phrase.match(%r{/.*/.*})
                      phrase.to_regexp
                    else
                      "/#{phrase}/".to_regexp
                    end
          end

          next if regex.nil?
          next unless regex.match?(msg)

          if mode.zero?
            matching_triggers.clear
            matching_triggers << t
            break
          end
          matching_triggers << t
        end

        # No matching triggers
        next if matching_triggers.empty?

        chosen_trigger = matching_triggers.sample

        if sure_trigger
          picked = true
        else
          chance = TohsakaBot.trigger_data.parse_chance(chosen_trigger[:chance], chosen_trigger[:mode])

          pickup = Pickup.new({ true => chance, false => 100 - chance })
          picked = pickup.pick(1)
        end

        # Doesn't send reply if the probability wasn't hit.
        next unless picked

        file = chosen_trigger[:file]
        reply = if file.to_s.empty?
                  event.respond chosen_trigger[:reply]
                else
                  event.channel.send_file(File.open("data/triggers/#{file}"))
                end

        # Incrementing trigger stats
        if sure_trigger
          TohsakaBot.db.transaction do
            TohsakaBot.db[:triggers].where(id: chosen_trigger[:id]).update(
              calls: chosen_trigger[:calls] + 1,
              last_triggered: Time.now
            )
          end
        else
          TohsakaBot.db.transaction do
            TohsakaBot.db[:triggers].where(id: chosen_trigger[:id]).update(
              occurences: chosen_trigger[:occurences] + 1,
              last_triggered: Time.now
            )
          end
        end

        # A way to remove the trigger response.
        # Only the one whose message got triggered is able to delete the response.
        # Threading is needed here as otherwise the await! would block any other triggers.
        Thread.new do
          response = event.message.await!(timeout: 10)
          if response && (CFG.del_trigger.include? response.content.downcase)
            reply.delete
            response.message.delete
          end
        end
      end
    end
  end
end
