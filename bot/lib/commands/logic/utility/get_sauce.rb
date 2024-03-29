# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class GetSauce
      def initialize(event, url)
        @event = event
        @url = url
      end

      def run
        if !@url.blank?
          url = @url
        elsif @event.instance_of?(Discordrb::Commands::CommandEvent) && @event.message.attachments.blank?
          url = @event.message.attachments&.first&.url
        else
          return { content: 'Attach an image file or a URL `sauce https://website.com/image.png` with the command' }
        end

        return { content: "URL was incorrect." } unless TohsakaBot.url_regex.match?(url)

        output = TohsakaBot.saucenao(@url)
        return { content: "Nothing found" } if output.nil?

        builder = Discordrb::Webhooks::Builder.new
        builder.add_embed do |e|
          e.title = 'Results:'
          e.colour = 0xA82727
          e.timestamp = TohsakaBot.time_now
          e.image = Discordrb::Webhooks::EmbedImage.new(url: @url)

          e.add_field(name: '**Pixiv**', value: "https://www.pixiv.net/en/artworks/#{output}")
          e.add_field(name: '**Pixiv.moe**', value: "https://pixiv.moe/illust/#{output}")
          # e.add_field(name: '**Website X**', value: 'URL')
          e.add_field(
            name: '**More results**',
            value: "[here!](https://saucenao.com/search.php?output_type=0&dbmask=32&url=#{url})"
          )
        end

        { content: nil, embeds: builder.embeds.map(&:to_hash) }
      end


    end
  end
end
