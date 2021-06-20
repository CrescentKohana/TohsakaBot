# frozen_string_literal: true

module TohsakaBot
  module Events
    module AnotherRoll
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :roll, delay: 10
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^roll:\d/) do |event|
        next if event.user.bot_account

        user_id = event.user.id.to_i
        name = BOT.member(event.server, user_id).display_name.sanitize_string

        roll_size = event.custom_id.split(':').last.to_i
        number = rand(0..("9" * roll_size).to_i).to_s
        content = "🎲 **#{number.rjust(roll_size, '0')}** `#{name}`"

        event.defer_update
        BOT.send_message(event.channel, content, false, nil, nil, false, event.message.message_reference)

        if /(\d)\1{3}/.match?(number) && i == 4
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_temporary_role(event, CFG.mvp_role.to_i, user_id, 7, "Quads")
          event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
        elsif /(\d)\1{4}/.match?(number) && i == 5
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_temporary_role(event, CFG.mvp_role.to_i, user_id, 7, "Quints")
          event.respond("🎉 @here #{name} HAS GOT QUINTS! 🎉")
        end
      end
    end
  end
end
