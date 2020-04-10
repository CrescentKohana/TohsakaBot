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
              @where = BOT.pm_channel(uid)
              # days = [1, 2, 3, 4, 5, 6, 7]

              if BOT.channel(cid).nil?
                @where = BOT.pm_channel(uid)
              else
                if BOT.channel(cid).pm?
                  @where = BOT.channel(cid)
                else
                  # If bot has permissions to send messages to this channel.
                  if BOT.profile.on(BOT.server(BOT.channel(cid).server.id)).permission?(:send_messages, BOT.channel(cid))
                    @where = BOT.channel(cid)
                  else
                    @where = BOT.pm_channel(uid)
                  end
                end
              end

              # Catching the exception if a user has blocked the bot
              # as Discord API has no way to check that naturally
              begin
                if msg.to_s.empty?
                  # TODO: For repeated reminders. Checks if today is included in the array
                  # which has the days the user wanted to be notified on.
                  # if rep != "false"
                  #  today = Date.today
                  #  if days.include? today
                  #  end
                  # end
                  # Raw API request: Discordrb::API::Channel.create_message("Bot #{AUTH.bot_token}", cid, "")
                  @where.send_message("#{repeated_msg}eminder for <@#{uid}>!")
                else
                  @where.send_message("#{repeated_msg}eminder for <@#{uid}>: #{msg.strip_mass_mentions}")
                end
              rescue
                # The user has blocked the bot.
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
