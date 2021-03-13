# frozen_string_literal: true

module TohsakaBot
  module Async
    module DailyNeko
      Thread.new do
        cfg = YAML.load_file('cfg/config.yml')
        last_time = cfg['daily_neko']

        loop do
          now = Time.now
          is_in_range = (
            Time.new(now.year, now.month, now.day, 13, 37, 0)..Time.new(now.year, now.month, now.day, 23, 59, 59)
          ).cover? Time.now

          if last_time == 'true' || (now.to_i >= last_time.to_i && is_in_range)
            last_time = now.to_i + 43_200 # 12h
            cfg['daily_neko'] = last_time
            File.open('cfg/config.yml', 'w') { |f| f.write cfg.to_yaml }

            url = TohsakaBot.get_neko('neko')

            BOT.channel(CFG.default_channel.to_i).send_embed do |embed|
              embed.image = Discordrb::Webhooks::EmbedImage.new(url: url)
              embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Daily 猫 (cat)')
              embed.colour = 0x36393F
              embed.timestamp = Time.now
            end
          end
          sleep(10)
        end
      end
    end
  end
end
