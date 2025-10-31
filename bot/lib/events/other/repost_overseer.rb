# frozen_string_literal: true

require 'dhash-vips'

module TohsakaBot
  module Events
    module RepostOverseer
      IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp .bmp .apng].freeze

      def self.notify(event, linked)
        return if event.server.id != linked[:server_id]

        user_obj = BOT.member(event.server, linked[:author_id])
        username = user_obj.nil? ? "Deleted user" : user_obj.display_name

        event.channel.send_embed do |embed|
          embed.colour = 0x36393F
          embed.add_field(
            name: "**WANHA** #{Discordrb.timestamp(linked[:timestamp], :relative)}",
            value: "By [#{username}](https://discord.com/channels/"\
                   "#{linked[:server_id]}/#{linked[:channel_id]}/#{linked[:msg_id]})"
          )
          embed.timestamp = linked[:timestamp]
        end
      end

      def self.repost_overseer(urls, time, event, edit: false)
        db = TohsakaBot.db[:linkeds]

        urls.each do |url|
          category, url_result = TohsakaBot.url_parse(url)
          break if category.nil?

          match = TohsakaBot.url_match(category, url_result, event.message.user.id)
          unless match.nil?
            notify(event, match)
            next
          end
          # next unless db.where(url: url_result).single_record.nil?
          next if edit

          TohsakaBot.db.transaction do
            db.insert(
              category: category,
              url: url_result,
              file_hash: nil,
              idhash: nil,
              timestamp: time,
              author_id: event.message.user.id,
              msg_id: event.message.id,
              channel_id: event.channel.id,
              server_id: event.server.id,
              created_at: TohsakaBot.time_now,
              updated_at: TohsakaBot.time_now
            )
          end
        end
        return if edit

        event.message.attachments.each do |file|
          file_name = file.filename.dup.add_identifier
          IO.copy_stream(URI.parse(file.url).open, "../tmp/#{file_name}")
          next unless File.exist?("../tmp/#{file_name}")

          file_hash = Digest::SHA2.file("../tmp/#{file_name}").to_s
          idhash = nil
          begin
            if IMAGE_EXTENSIONS.include?(File.extname(file.filename).downcase)
              idhash = DHashVips::IDHash.fingerprint("../tmp/#{file_name}")
            end
          rescue Vips::Error
            # ignore, not an image
          end

          File.delete("../tmp/#{file_name}") if File.exist?("tmp/#{file_name}")

          file_hash_match = TohsakaBot.file_hash_match(file_hash, event.message.user.id)
          unless file_hash_match.nil?
            notify(event, file_hash_match)
            next
          end

          unless idhash.nil?
            idhash_match = TohsakaBot.idhash_match(idhash, event.message.user.id)
            unless idhash_match.nil?
              notify(event, idhash_match)
              next
            end
          end

          TohsakaBot.db.transaction do
            db.insert(
              category: idhash.nil? ? 'file' : 'image',
              url: '',
              file_hash: file_hash,
              idhash: idhash.to_s,
              timestamp: time,
              author_id: event.message.user.id,
              msg_id: event.message.id,
              channel_id: event.channel.id,
              server_id: event.server.id,
              created_at: TohsakaBot.time_now,
              updated_at: TohsakaBot.time_now
            )
          end
        end
      end

      extend Discordrb::EventContainer
      message do |event|
        next unless TohsakaBot.url_regex.match?(event.message.content) || !event.message.attachments.empty?

        cleaned_msg = TohsakaBot.strip_markdown(event.message.content)
        urls = URI.extract(cleaned_msg)
        time = event.message.timestamp

        repost_overseer(urls, time, event)
      end

      message_edit do |event|
        next unless TohsakaBot.url_regex.match?(event.message.content) || !event.message.attachments.empty?

        cleaned_msg = TohsakaBot.strip_markdown(event.message.content)
        urls = URI.extract(cleaned_msg)
        time = event.message.timestamp

        repost_overseer(urls, time, event, edit: true)
      end
    end
  end
end
