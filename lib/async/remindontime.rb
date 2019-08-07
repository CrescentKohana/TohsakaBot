module TohsakaBot
  module Async
    module RemindOnTime
      Thread.new do
        loop do

          remindb = YAML.load_file('data/reminders.yml')
          timen = Time.now.to_i

          remindb.each do |key, value|
            time = value["time"].to_i

            if timen >= time

              msg = value["message"]
              uid = value["user"].to_i
              cid = value["channel"].to_i
              rep = value["repeat"]
              repeated_msg = rep != "false" ? "Repeated r" : "R"
              # days = [1, 2, 3, 4, 5, 6, 7]

              @where = if BOT.channel(cid).nil?
                            BOT.pm_channel(uid)
                          else
                            BOT.channel(cid)
                          end

              if msg.to_s.empty?

                # TODO: For repeated reminders. Checks if today is included in the array
                # which has the days the user wanted to be notified on.
                # if rep != "false"
                #  today = Date.today
                #  if days.include? today
                #  end
                # end

                # Raw API request: Discordrb::API::Channel.create_message("Bot #{$config['bot_token']}", cid, "")
                @where.send_message("#{repeated_msg}eminder for <@#{uid}>!")
              else
                @where.send_message("#{repeated_msg}eminder for <@#{uid}>: #{msg.strip_mass_mentions}")
              end

              rstore = YAML::Store.new('data/reminders.yml')
              rstore.transaction do
                rstore.delete(key)

                if rep != "false"
                  rstore[key] = {"time" => time.seconds + rep.to_i, "message" => "#{msg}", "user" => "#{uid}", "channel" =>"#{cid}", "repeat" =>"#{rep}" }
                end

                rstore.commit
              end
            end
          end
          sleep(1)
        end
      end
    end
  end
end
