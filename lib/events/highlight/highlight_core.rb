module TohsakaBot
  class HighlightCore
    @highlight_channel
    @db

    @message
    @attachments
    @server_id
    @channel_id

    def initialize(message, server_id, channel_id)
      @highlight_channel = BOT.channel(CFG.highlight_channel)
      @db = TohsakaBot.db[:highlights]

      @message = message
      @attachments = message.attachments.map { |a| a.url }.join("\t")

      @server_id = server_id.to_i
      @channel_id = channel_id.to_i
    end

    def requirements_for_pin_met?
      # Users with permission 500 or above can pin messages immediately
      authorized_users = TohsakaBot.db[:users].where(Sequel[:permissions] >= 500).map { |u|
        TohsakaBot.get_discord_id(u[:id])
      }

      reacted_users = @message.reacted_with('📌').map(&:id)

      # true if authorized
      is_authorized = reacted_users.to_set.intersect?(authorized_users.to_set)

      return false unless @db.where(:msg_id => @message.id, :deleted => false).empty?
      return false if !@db.where(:msg_id => @message.id, :deleted => true).empty? && !is_authorized
      reacted_users.length >= 3 || is_authorized
    end

    def serialize_attachments(attachments)
      attachments.join"\t"
    end

    def store_highlight(highlight_msg_id)
      @db.where(:highlight_msg_id => highlight_msg_id).delete

      TohsakaBot.db.transaction do
        @db.insert(content: @message.content,
                   attachments: @attachments,
                   author_id: @message.author.id,
                   timestamp: @message.timestamp,
                   msg_id: @message.id,
                   channel: @channel_id,
                   highlight_msg_id: highlight_msg_id,
                   server: @server_id,
                   deleted: false,
                   created_at: Time.now,
                   updated_at: Time.now)
      end
    end

    def self.delete_highlight(id, force: false)
      db = TohsakaBot.db[:highlights]
      id = id.to_i
      if force
        db.where(:highlight_msg_id => id).delete
      else
        highlight = db.where(:highlight_msg_id => id).first
        highlight[:deleted] = true
        db.where(:highlight_msg_id => id).update(highlight)
      end
    end

    def send_highlight
      content = @message.content
      attachment_names = @message.attachments.map { |a| a.filename }.join("\n")

      main_attachment = "-"
      main_attachment = @message.attachments[0].url unless @message.attachments.empty?
      is_image = %w[.jpg .png .jpeg .JPG .PNG .JPEG .gif].include?(File.extname(main_attachment))
      # is_video = %w[.mp4 .webm].include?(File.extname(main_attachment))

      sent_msg = @highlight_channel.send_embed do |embed|
        embed.colour = 0xA82727
        embed.timestamp = @message.timestamp

        embed.image = Discordrb::Webhooks::EmbedImage.new(url: main_attachment) if is_image

        embed.add_field(name: "Message", value: content) unless content.blank?
        embed.add_field(name: "Files", value: attachment_names) if @message.attachments.length > 1 || (@message.attachments.length == 1 && !is_image)
        embed.add_field(
          name: "→",
          value: "[Link to original](https://discord.com/channels/#{@server_id}/#{@channel_id}/#{@message.id}) in <##{@channel_id}>"
        )

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: @message.author.display_name,
          icon_url: @message.author.avatar_url
        )
      end

      ### Webhook version ###
      # wh = Discordrb::API::Channel.create_webhook("Bot #{AUTH.bot_token}", @highlight_channel.id.to_i, "Highlight", @message.author.avatar_url, "Custom msg pin")
      # #wh = BOT.channel(@highlight_channel.id.to_i).create_webhook("Highlight", @message.author.avatar_url)
      # wh = Discordrb::Webhooks::Client.new(id: JSON.parse(wh)['id'], token: JSON.parse(wh)['token'])
      #
      # sent_msg = wh.execute do |msg|
      #   msg.username =  @message.author.display_name
      #   msg.avatar_url = @message.author.avatar_url
      #
      #   msg.content = content unless content.blank?
      #
      #   msg.add_embed do |embed|
      #     embed.colour = 0xFDFDFD
      #     embed.timestamp = @message.timestamp
      #     embed.image = Discordrb::Webhooks::EmbedImage.new(url: main_attachment) if is_image
      #     embed.add_field(name: "Files", value: attachment_names) if @message.attachments.length > 1 || (@message.attachments.length == 1 && !is_image)
      #     embed.add_field(name: "→",
      #                     value: "[Original](https://discord.com/channels/#{@server_id}/#{@channel_id}/#{@message.id}) in <##{@channel_id}>")
      #     embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: @message.author.display_name)
      #   end
      # end

      sent_msg.id
    end
  end
end
