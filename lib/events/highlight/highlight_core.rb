module TohsakaBot
  class HighlightCore
    @highlight_channel
    @message
    @server_id
    @channel_id

    def initialize(message, server_id, channel_id)
      @message = message
      @server_id = server_id.to_i
      @channel_id = channel_id.to_i
      @highlight_channel = BOT.channel(CFG.highlight_channel)
    end

    def requirements_for_pin_met?
      reacted_users = @message.reacted_with('📌').map(&:id)

      # Users with permission 500 or above can pin messages immediately
      authorized_users = TohsakaBot.db[:users].where(Sequel[:permissions] >= 500).map { |u|
        TohsakaBot.get_discord_id(u[:id])
      }

      reacted_users.length >= 3 || reacted_users.to_set.intersect?(authorized_users.to_set)
    end

    def send_highlight
      content = @message.content

      @highlight_channel.send_embed do |embed|
        #embed.title = "Highlight Alpha Test"
        embed.colour = 0xA82727
        embed.timestamp = @message.timestamp
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: @message.author.display_name)
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: @message.attachments[0].url) if @message.attachments.length > 0

        embed.add_field(name: "Message", value: content) unless content.blank?

        embed.add_field(
          name: "→",
          value: "[Link to original](https://discord.com/channels/#{@server_id}/#{@channel_id}/#{@message.id})"
        )
      end

      # wh = Discordrb::API::Channel.create_webhook("Bot #{AUTH.bot_token}", @highlight_channel.id, "Highlighter", @message.author.avatar_url, nil)
      # id = JSON.parse(wh)['id']
      # token = JSON.parse(wh)['token']
      # wh = Discordrb::Webhooks::Client.new(id: id, token: token)
      #
      # wh.execute {|msg|
      #   msg.username =  @message.author.display_name
      #   msg.avatar_url = @message.author.avatar_url
      #
      #   msg.content = content unless content.blank?
      #
      #   msg.add_embed do |embed|
      #     embed.colour = 0xA82727
      #     embed.timestamp = @message.timestamp
      #     embed.image = Discordrb::Webhooks::EmbedImage.new(url: @message.attachments[0].url) if @message.attachments.length > 0
      #
      #     embed.add_field(
      #       name: "→",
      #       value: "[Link to original](https://discord.com/channels/#{@server_id}/#{@channel_id}/#{@message.id})"
      #     )
      #   end
      # }
    end
  end
end
