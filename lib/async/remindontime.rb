module TohsakaBot
  module Async
    module RemindOnTime
      # require 'active_support/time_with_zone'
      # require 'active_support/core_ext/numeric/time'
      # require 'active_support/core_ext/string/filters'
      Thread.new do
        # Dirty iteration
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

              if msg.to_s.empty?
                BOT.channel(cid.to_i).send_message("Reminder for <@#{uid.to_i}>!")
              else
                BOT.channel(cid.to_i).send_message("Reminder for <@#{uid.to_i}>: #{msg.hide_link_preview}")
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
