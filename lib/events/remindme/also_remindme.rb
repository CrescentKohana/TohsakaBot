module TohsakaBot
  module Events
    module AlsoRemindme
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :remindme, delay: 360
      extend Discordrb::EventContainer
      reaction_add(emoji: '🔔') do |event|
        original_user_id = event.message.author.id.to_i
        user_id = event.user.id.to_i
        msg = event.message.content

        next if !event.message.author.current_bot? || event.user.bot_account || !TohsakaBot.registered?(user_id)
        next if user_id == original_user_id
        next if rate_limiter.rate_limited?(:remindme, event.user)

        reminder_id = msg.match(/`<ID (\d*)>`/).captures.first.to_i
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
