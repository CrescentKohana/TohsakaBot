module TohsakaBot
  module Async
    module RemindOnTime
      Thread.new do
        reminders = TohsakaBot.db[:reminders]
        loop do
          time_now = Time.now
          expiring_reminders = reminders.where(Sequel[:datetime] <= time_now)

          expiring_reminders.each do |r|
            id = r[:id].to_i
            datetime = r[:datetime].to_i
            msg = r[:message]
            cid = r[:channel].to_i
            created_at = r[:created_at]
            updated_at = r[:updated_at]
            user_id = r[:user_id].to_i

            # Legacy
            if user_id.to_s.size > 16
              discord_uid = user_id
            else
              discord_uid = TohsakaBot.get_discord_id(user_id)
            end

            repeat_time = r[:repeat].to_i
            repeated_msg = repeat_time > 0 ? "Repeated r" : "R"

            @where = BOT.pm_channel(discord_uid)

            if BOT.channel(cid).nil?
              @where = BOT.pm_channel(discord_uid)
            else
              if BOT.channel(cid).pm?
                @where = BOT.channel(cid)
              else
                # If bot has permissions to send messages to this channel.
                if BOT.profile.on(BOT.server(BOT.channel(cid).server.id)).permission?(:send_messages, BOT.channel(cid))
                  @where = BOT.channel(cid)
                else
                  @where = BOT.pm_channel(discord_uid)
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
                @where.send_message("#{repeated_msg}eminder for <@#{discord_uid}>!")
              else
                @where.send_message("#{repeated_msg}eminder for <@#{discord_uid}>: #{msg.strip_mass_mentions}")
              end
            rescue
              # The user has blocked the bot.
            end

            if repeat_time > 0
              TohsakaBot.db.transaction do
                reminders.insert(datetime: (datetime + repeat_time.to_i).strftime('%Y-%m-%d %H:%M:%S'),
                                 message: msg,
                                 user_id: user_id,
                                 channel: cid,
                                 repeat: repeat_time,
                                 created_at: created_at,
                                 updated_at: updated_at)
              end
            else
              TohsakaBot.db.transaction do
                reminders.where(:id => id).delete
              end
            end
          end
          sleep(1)
        end
      end
    end
  end
end
