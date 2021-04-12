# frozen_string_literal: true

module TohsakaBot
  module Events
    module URLCollector
      extend Discordrb::EventContainer
      message(content: TohsakaBot.url_regex) do |event|
        cleaned_msg = TohsakaBot.strip_markdown(event.message.content)
        urls = URI.extract(cleaned_msg)

        discord_uid = event.message.user.id
        time = Time.parse(event.message.timestamp.to_s)

        def self.store_repost(urls, time, file_hash, discord_uid, msg_id, channel_id, server_id)
          db = TohsakaBot.db[:linkeds]

          urls.each do |url|
            category, url_result = TohsakaBot.url_parse(url)
            break if category.nil?
            next unless db.where(url: url_result).single_record.nil?
            next if !file_hash.blank? && !db.where(file_hash: url_result).single_record.nil?

            TohsakaBot.db.transaction do
              db.insert(
                category: category,
                url: url_result,
                file_hash: file_hash,
                timestamp: time,
                author_id: discord_uid,
                msg_id: msg_id,
                channel_id: channel_id,
                server_id: server_id,
                created_at: Time.now,
                updated_at: Time.now
              )
            end
          end
        end

        # TODO: File checksum check?
        # unless event.message.attachments.empty
        #   file = event.message.attachments.first
        #   IO.copy_stream(URI.open(file.url), "tmp/#{}")
        #   store_repost(db, event, url, ti, file, ui, url_to_msg)
        # end
        # file = ''

        store_repost(urls, time, '', discord_uid, event.message.id, event.channel.id, event.server.id)
      end
    end
  end
end
