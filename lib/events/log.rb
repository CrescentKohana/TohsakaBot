module TohsakaBot
  module Events
    module Log
      extend Discordrb::EventContainer
      message(content: $url_regexp) do |event|
        url = URI.extract(event.message.content)
        ui = event.message.user.id
        # ci = event.channel.id
        ti = Time.parse(event.message.timestamp.to_s).to_i
        url_to_msg = "https://discordapp.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id}"

        def self.store_repost(db, _e, url, ti, file, ui, url_to_msg)
          url.each do |u|
            $excluded_urls.each do |k, v|
              if u =~ v["url"].to_regexp(detect: true)
                break
              end
            end

            db.transaction do
              i = 1
              until db.root?(i) != true
                i += 1
              end
              db[i] = {"url" => "#{u}", "time" => ti, "file" => "#{file}", "user" => "#{ui}", "msg_url" =>"#{url_to_msg}" }
              db.commit
            end
          end

          #timen = Time.now.to_i
          #rdb.each do |key, value|
          #  if url[0] == value["url"]
          #    rstore = YAML::Store.new('data/repost.yml')
          #    rstore.transaction do
          #      rstore.commit
          #    end
          #  end
          #end

          #current_triggers = []
          #pos = 0
          #triggers.each do |key, value|
          #  if event.author.id.to_i == value["user"].to_i
          #    current_triggers << [key, value["trigger"].to_s, value["reply"].to_s, value["file"].to_s, value["user"]]
          #    if current_triggers[pos][2].empty?
          #      output << "#{sprintf("%4s", current_triggers[pos][0])} | #{sprintf("%-50s", current_triggers[pos][1][0..50])} | #{current_triggers[pos][3][0..25]}\n"
          #    else
          #      output << "#{sprintf("%4s", current_triggers[pos][0])} | #{sprintf("%-50s", current_triggers[pos][1][0..50])} | #{current_triggers[pos][2][0..25]}\n"
          #    end
          #    pos += 1
          #  end
          #end
        end

        db = YAML::Store.new('data/repost.yml')
        # dbr = YAML.load_file('data/repost.yml')
        e = event

        if event.message.attachments.first.nil? && 1 == 0
          file = event.message.attachments.first.filename
          store_repost(db, e, url, ti, file, ui, url_to_msg)
        elsif 1.zero?
          file = event.message.attachments.first.filename
          store_repost(db, e, url, ti, file, ui, url_to_msg)
        else
          file = ''
          store_repost(db, e, url, ti, file, ui, url_to_msg)
        end
      end
    end
  end
end
