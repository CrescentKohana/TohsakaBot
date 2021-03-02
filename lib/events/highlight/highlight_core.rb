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
      @attachments = message.attachments.map(&:url).join("\t")

      @server_id = server_id.to_i
      @channel_id = channel_id.to_i
    end

    def requirements_for_pin_met?
      # Users with permission 250 or above can pin messages immediately
      authorized_users = TohsakaBot.db[:users].where(Sequel[:permissions] >= 250).map { |u|
        TohsakaBot.get_discord_id(u[:id])
      }

      reacted_users = @message.reacted_with('📌').map(&:id)

      # true if authorized
      is_authorized = reacted_users.to_set.intersect?(authorized_users.to_set)

      return false unless @db.where(msg_id: @message.id, deleted: false).empty?
      return false if !@db.where(msg_id: @message.id, deleted: true).empty? && !is_authorized

      reacted_users.length >= 3 || is_authorized
    end

    def serialize_attachments(attachments)
      attachments.join "\t"
    end

    def store_highlight(highlight_msg_id)
      @db.where(highlight_msg_id: highlight_msg_id).delete

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
        db.where(highlight_msg_id: id).delete
      else
        highlight = db.where(highlight_msg_id: id).first
        highlight[:deleted] = true
        db.where(highlight_msg_id: id).update(highlight)
      end
    end

    def send_highlight
      # If the user id deleted: it's Discordrb::User, not Discordrb::Member
      author_name = @message.author.is_a? Discordrb::User ? @message.author.username : @message.author.display_name

      content = @message.content
      attachment_names = @message.attachments.map(&:filename).join("\n")

      is_image = false

      unless @message.attachments.empty?
        main_attachment = @message.attachments[0]

        is_image = %w[.jpg .png .jpeg .JPG .PNG .JPEG .gif].include?(File.extname(main_attachment.filename))
        is_video = %w[.mp4 .webm .mov].include?(File.extname(main_attachment.filename))
        is_audio = %w[.wav .flac .ogg .mp3].include?(File.extname(main_attachment.filename))

        if main_attachment.size < TohsakaBot::DiscordHelper::UPLOAD_LIMIT && (is_video || is_audio)
          filename = temp_download_file(main_attachment)
          @highlight_channel.send_file(File.open("tmp/#{filename}"), spoiler: main_attachment.spoiler?)
          File.delete("tmp/#{filename}")
        end
      end

      sent_msg = @highlight_channel.send_embed do |embed|
        embed.colour = 0xA82727
        embed.timestamp = @message.timestamp

        embed.image = Discordrb::Webhooks::EmbedImage.new(url: main_attachment.url) if is_image

        embed.add_field(name: 'Message', value: content.truncate(1024)) unless content.blank?
        embed.add_field(name: 'Files', value: attachment_names) if @message.attachments.length > 1 || (@message.attachments.length == 1 && !is_image)
        embed.add_field(
          name: '→',
          value: "[Link to original](https://discord.com/channels/#{@server_id}/#{@channel_id}/#{@message.id}) in <##{@channel_id}>"
        )

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: author_name,
          icon_url: @message.author.avatar_url
        )
      end

      sent_msg.id
    end

    def temp_download_file(attachment)
      return unless %r{https://cdn.discordapp.com.*}.match?(attachment.url)

      filename = attachment.filename
      IO.copy_stream(URI.open(attachment.url), "tmp/#{filename}")
      filename
    end
  end
end
