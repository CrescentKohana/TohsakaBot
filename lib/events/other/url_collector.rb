module TohsakaBot
  module Events
    module URLCollector
      extend Discordrb::EventContainer
      message(content: TohsakaBot.url_regex) do |event|
        cleaned_msg = TohsakaBot.strip_markdown(event.message.content)
        urls = URI.extract(cleaned_msg)

        discord_uid = event.message.user.id
        time = Time.parse(event.message.timestamp.to_s).to_i
        msg_uri = "#{event.server.id}/#{event.channel.id}/#{event.message.id}"

        def self.store_repost(urls, time, file, discord_uid, msg_uri)
          db = YAML::Store.new('data/repost.yml')
          entry_exists = false

          urls.each do |url|
            type, url_result = TohsakaBot.url_parse(url)
            break if type.nil?

            db_read = YAML.load_file('data/repost.yml')
            db_read&.each do |_k, v|
              if v['url'] == url_result
                entry_exists = true
                break
              end
            end

            next if entry_exists

            db.transaction do
              i = 1
              i += 1 while db.root?(i)
              db[i] = {
                'type' => type.to_s,
                'url' => url_result.to_s,
                'time' => time,
                'file' => file.to_s,
                'user' => discord_uid,
                'msg_uri' => msg_uri.to_s
              }
              db.commit
            end
          end
        end

        # TODO: File checksum check?
        # if !event.message.attachments.first.nil?
        #   file = event.message.attachments.first.filename
        #   store_repost(db, event, url, ti, file, ui, url_to_msg)
        # end
        # file = ''

        store_repost(urls, time, '', discord_uid, msg_uri)
      end
    end
  end
end
