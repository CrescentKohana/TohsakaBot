# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsRenew
      extend Discordrb::EventContainer
      reaction_add(emoji: '🔄') do |event|
        next if event.channel.pm? || event.user.bot_account
        next if TohsakaBot.time_now.to_i < event.message.timestamp.to_i + 3600

        msg = event.respond(
          "#{event.message.content} by <@!#{event.user.id}>",
          false,
          nil,
          nil,
          parse: %w[users roles]
        )
        event.message.delete

        emoji = %w[✅ ❌ 🚫 🔕 ❓]
        emoji.each do |e|
          msg.create_reaction(e)
        end
      end
    end
  end
end
