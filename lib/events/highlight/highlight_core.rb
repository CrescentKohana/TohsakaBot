# frozen_string_literal: true

module TohsakaBot
  class HighlightCore
    def initialize(message, server_id, channel_id)
      @highlight_channel = BOT.channel(CFG.highlight_channel)
      @db = TohsakaBot.db[:highlights]

      @message = message
      @attachments = message.attachments.map(&:url).join("\t")

      @server_id = server_id.to_i
      @channel_id = channel_id.to_i
    end

    def requirements_for_pin_met?
      # If message is already highlighted
      return false unless @db.where(msg_id: @message.id, deleted: false).empty?

      # Users with force_highlight permission can highlight messages immediately
      authorized_users = TohsakaBot.db[:users].where(Sequel[:permissions] >= TohsakaBot.permissions.actions["force_highlight"]).map do |u|
        TohsakaBot.get_discord_id(u[:id])
      end

      reacted_users = Set.new(@message.reacted_with('📌').map(&:id))
      reacted_users.merge(Set.new(@message.reacted_with('📍').map(&:id)))

      # true if authorized
      is_authorized = reacted_users.intersect?(authorized_users.to_set)

      return false if !@db.where(msg_id: @message.id, deleted: true).empty? && !is_authorized

      reacted_users.size == 3 || is_authorized
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
                   channel_id: @channel_id,
                   highlight_msg_id: highlight_msg_id,
                   server_id: @server_id,
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
        if highlight
          highlight[:deleted] = true
          db.where(highlight_msg_id: id).update(highlight)
        end
      end
    end

    def send_highlight(server_id)
      # If user is deleted: it's Discordrb::User, not Discordrb::Member
      author_name = if @message.author.is_a?(Discordrb::User)
                      @message.author.username
                    else
                      @message.author.display_name
                    end

      content = @message.content
      attachment_names = @message.attachments.map(&:filename).join("\n")

      is_image = false

      unless @message.attachments.empty?
        main_attachment = @message.attachments[0]

        is_image = %w[.jpg .png .jpeg .JPG .PNG .JPEG .gif].include?(File.extname(main_attachment.filename))
        is_video = %w[.mp4 .webm .mov].include?(File.extname(main_attachment.filename))
        is_audio = %w[.wav .flac .ogg .mp3].include?(File.extname(main_attachment.filename))

        if main_attachment.size < TohsakaBot.server_upload_limit(server_id) && (is_video || is_audio)
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
        if @message.attachments.length > 1 || (@message.attachments.length == 1 && !is_image)
          embed.add_field(name: 'Files',
                          value: attachment_names)
        end
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
