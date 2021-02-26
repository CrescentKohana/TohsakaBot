module TohsakaBot
  module Events
    module AlsoRemindme
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :remindme, delay: 5
      extend Discordrb::EventContainer
      reaction_add(emoji: '🔔') do |event|
        next if event.channel.pm?

        user_id = event.user.id.to_i
        msg = event.message.content

        reminder_id = msg.match(/`<ID (\d*)>`/).captures.first.to_i

        next if !event.message.author.current_bot? || event.user.bot_account || !TohsakaBot.registered?(user_id)
        next if rate_limiter.rate_limited?(:remindme, event.user)
        next if user_id == TohsakaBot.get_discord_id(ReminderController.get_reminder(reminder_id)[:user_id])
        next if ReminderController.copy_already_exists?(reminder_id, user_id)

        new_reminder_id = ReminderController.copy_reminder(reminder_id, user_id)

        event.channel.send_embed do |embed|
          embed.colour = 0x36393F
          embed.add_field(
            name: "I will remind #{event.user.display_name} as well `<ID #{new_reminder_id}>`.",
            value: "[Original reminder](https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id}) <ID: #{reminder_id}>"
          )
        end unless new_reminder_id.nil?
      end
    end
  end
end
