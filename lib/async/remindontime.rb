module TohsakaBot
  module Async
    module RemindOnTime
      Thread.new do
        loop do

          remindb = YAML.load_file('data/reminders.yml')
          timen = Time.now.to_i

          remindb.each do |key, value|

            time = value["time"]

            if timen >= time.to_i

              msg = value["message"]
              uid = value["user"]
              cid = value["channel"]
              rep = value["repeat"]
              repeated_msg = rep != "false" ? "Repeated r" : "R"
              # days = [1, 2, 3, 4, 5, 6, 7]

              if msg.to_s.empty?

                # TODO: For repeated reminders. Checks if today is included in the array
                # which has the days the user wanted to be notified on.
                # if rep != "false"
                #  today = Date.today
                #  if days.include? today
                #  end
                # end

                BOT.channel(cid.to_i).send_message("#{repeated_msg}eminder  for <@#{uid.to_i}>!")
              else
                BOT.channel(cid.to_i).send_message("#{repeated_msg}eminder  for <@#{uid.to_i}>: #{msg.hide_link_preview}")
              end

              rstore = YAML::Store.new('data/reminders.yml')
              rstore.transaction do
                rstore.delete(key)

                if rep != "false"
                  rstore[key] = {"time" => rep.to_i.seconds.from_now, "message" => "#{msg}", "user" => "#{uid}", "channel" =>"#{cid}", "repeat" =>"#{rep}" }
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
