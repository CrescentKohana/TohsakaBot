# frozen_string_literal: true

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
            msg = r[:message]
            channel_id = r[:channel_id]
            datetime = r[:datetime].to_i
            # parent = r[:parent]
            created_at = r[:created_at]
            updated_at = r[:updated_at]
            user_id = r[:user_id].to_i
            discord_uid = TohsakaBot.get_discord_id(user_id)

            next if discord_uid.nil?
            next if BOT.user(discord_uid).bot_account?

            repeat_time = r[:repeat].to_i
            repeated_msg = repeat_time.positive? ? 'Repeated r' : 'R'

            # TODO: copied reminders in the same message if possible
            # if !parent.nil? && !reminders.where(:id => parent.to_i).nil?
            #
            # end

            @where = BOT.pm_channel(discord_uid)
            if channel_id.nil? || channel_id.zero?
              @where = BOT.pm_channel(discord_uid)
            elsif BOT.channel(channel_id).nil?
              @where = BOT.pm_channel(discord_uid)
            elsif BOT.channel(channel_id)&.pm?
              @where = BOT.channel(channel_id)
            else
              # If bot has permissions to send messages to this channel.
              temp_server = BOT.server(BOT.channel(channel_id).server.id)
              @where = if temp_server.nil?
                         BOT.pm_channel(discord_uid)
                       elsif BOT.profile.on(temp_server).permission?(:send_messages, BOT.channel(channel_id))
                         BOT.channel(channel_id)
                       else
                         BOT.pm_channel(discord_uid)
                       end
            end

            # Catching the exception if a user has blocked the bot
            # as Discord API has no way to check that naturally
            begin
              if msg.nil? || msg.empty?
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
            rescue StandardError
              # Ignored
              # as the user has blocked the bot.
            end

            if repeat_time.positive?
              TohsakaBot.db.transaction do
                reminders
                  .where(id: id)
                  .update(datetime: Time.at(datetime + repeat_time).strftime('%Y-%m-%d %H:%M:%S'),
                          message: msg,
                          user_id: user_id,
                          channel_id: channel_id,
                          repeat: repeat_time,
                          created_at: created_at,
                          updated_at: updated_at)
              end
            else
              TohsakaBot.db.transaction do
                reminders.where(id: id).delete
              end
            end
          end
          sleep(1)
        end
      end
    end
  end
end
