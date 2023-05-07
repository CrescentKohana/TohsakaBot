# frozen_string_literal: true

module TohsakaBot
  module Jobs
    def self.daily_neko(now)
      cfg = YAML.load_file('../cfg/config.yml')
      last_time = cfg['daily_neko']

      is_in_range = (
        Time.new(now.year, now.month, now.day, 13, 37, 0)..Time.new(now.year, now.month, now.day, 23, 59, 59)
      ).cover? now
      return unless last_time == 'true' || (now.to_i >= last_time.to_i && is_in_range)

      last_time = now.to_i + 43_200 # 12h
      cfg['daily_neko'] = last_time
      File.open('../cfg/config.yml', 'w') { |f| f.write cfg.to_yaml }

      url = TohsakaBot.get_neko('neko')
      pixiv_id = TohsakaBot.saucenao(url)

      builder = Discordrb::Webhooks::Builder.new
      builder.add_embed do |e|
        e.image = Discordrb::Webhooks::EmbedImage.new(url: url)
        e.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Daily 猫 (cat)')
        e.colour = 0x36393F
        e.timestamp = TohsakaBot.time_now
      end

      button = if pixiv_id.nil?
                 nil
               else
                 Discordrb::Components::View.new do |v|
                   v.row do |r|
                     r.button(style: :link, label: 'Source', url: "https://www.pixiv.net/en/artworks/#{pixiv_id}")
                   end
                 end
               end

      TohsakaBot.server_cache.each do |_id, server|
        next unless server[:daily_neko]

        BOT.send_message(
          server[:default_channel],
          '',
          false,
          builder.embeds.map(&:to_hash).first,
          nil,
          false,
          nil,
          button
        )
      end
    end
  end
end
