# frozen_string_literal: true

module TohsakaBot
  module Events
    module AlsoRemindme
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^reminder_(add|mod):\d+/) do |event|
        next if event.channel.pm?

        event.defer_update

        user_id = event.user.id.to_i
        reminder_id = event.custom_id.split(':').last.to_i

        next if reminder_id.nil?
        next unless TohsakaBot.registered?(user_id)

        parent_reminder = ReminderController.get_reminder(reminder_id)
        next if parent_reminder.nil?
        next if user_id == TohsakaBot.get_discord_id(parent_reminder[:user_id])
        next if ReminderController.copy_already_exists?(reminder_id, user_id)

        new_reminder_id = ReminderController.copy_reminder(reminder_id, user_id)
        next if new_reminder_id.nil?

        TohsakaBot.queue_cache.add_msg(
          [
            "I will remind #{event.user.display_name} as well `<ID #{new_reminder_id}>`.",
            "[Original reminder]"\
            "(https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id}) "
          ],
          event.channel.id.to_i,
          user_id,
          true
        )
      end
    end
  end
end
