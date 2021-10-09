# frozen_string_literal: true

module TohsakaBot
  module Events
    module RepostOverseer
      def self.notify(event, linked)
        user_obj = BOT.member(event.server, linked[:author_id])
        username = user_obj.nil? ? "Deleted user" : user_obj.display_name
        time = Time.use_zone('UTC') { Time.zone.local(*linked[:timestamp]) }

        event.channel.send_embed do |embed|
          embed.colour = 0x36393F
          embed.add_field(
            name: "**WANHA** #{Discordrb.timestamp(time, :relative)}",
            value: "By [#{username}](https://discord.com/channels/"\
                   "#{linked[:server_id]}/#{linked[:channel_id]}/#{linked[:msg_id]})"
          )
          embed.timestamp = time
        end
      end

      def self.repost_overseer(urls, time, event)
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

          TohsakaBot.db.transaction do
            db.insert(
              category: category,
              url: url_result,
              file_hash: '',
              timestamp: time,
              author_id: event.message.user.id,
              msg_id: event.message.id,
              channel_id: event.channel.id,
              server_id: event.server.id,
              created_at: Time.now,
              updated_at: Time.now
            )
          end
        end

        event.message.attachments.each do |file|
          file_name = file.filename.dup.add_identifier
          IO.copy_stream(URI.parse(file.url).open, "tmp/#{file_name}")
          file_hash = Digest::SHA2.file("tmp/#{file_name}").to_s

          match = TohsakaBot.file_hash_match(file_hash, event.message.user.id)
          unless match.nil?
            notify(event, match)
            next
          end

          File.delete("tmp/#{file_name}")
          # next unless db.where(file_hash: file_hash).single_record.nil?

          TohsakaBot.db.transaction do
            db.insert(
              category: 'file',
              url: '',
              file_hash: file_hash,
              timestamp: time,
              author_id: event.message.user.id,
              msg_id: event.message.id,
              channel_id: event.channel.id,
              server_id: event.server.id,
              created_at: Time.now,
              updated_at: Time.now
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
    end
  end
end
