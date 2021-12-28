# frozen_string_literal: true

module TohsakaBot
  module Jobs
    def self.remind_on_time(now)
      reminders = TohsakaBot.db[:reminders]
      expiring_reminders = reminders.where(Sequel[:datetime] <= now)

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

        # TODO: copied reminders in the same message if possible
        # if !parent.nil? && !reminders.where(:id => parent.to_i).nil?
        #
        # end

        @where = BOT.pm_channel(discord_uid)
        if channel_id.blank? || channel_id.zero?
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

        # Catching the exception if a user has blocked the bot as Discord API has no way to check that naturally
        begin
          response = if repeat_time.positive?
                       I18n.t(:'async.reminder.repeated', mention: "<@#{discord_uid}>")
                     else
                       I18n.t(:'async.reminder.normal', mention: "<@#{discord_uid}>")
                     end

          response += ": #{msg.strip_mass_mentions}" unless msg.blank?
          @where.send_message(response, false, nil, nil, { users: [discord_uid] })
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
    end
  end
end
