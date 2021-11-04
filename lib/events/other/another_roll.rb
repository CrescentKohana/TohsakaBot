# frozen_string_literal: true

module TohsakaBot
  module Events
    module AnotherRoll
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :roll, delay: 10
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^roll:(\d|id)/) do |event|
        next if event.user.bot_account

        user_id = event.user.id.to_i
        name = BOT.member(event.server, user_id).display_name.sanitize_string

        event_id = event.custom_id.split(':').last
        number = '0'
        if /\d/.match(event_id)
          roll_size = event_id.to_i
          number = rand(0..("9" * roll_size).to_i).to_s
          content = "🎲 **#{number.rjust(roll_size, '0')}** `#{name}`"
        else
          content = "#{CommandLogic::Roll.parse_msg_id(event.interaction.id)} `#{name}`"
        end

        event.defer_update
        BOT.send_message(event.channel, content, false, nil, nil, false, event.message.message_reference)

        if /(\d)\1{3}/.match?(number) && i == 4
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_trophy(event, CFG.mvp_role.to_i, user_id, 7, "Quads")
          event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
        elsif /(\d)\1{4}/.match?(number) && i == 5
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_trophy(event, CFG.mvp_role.to_i, user_id, 7, "Quints")
          event.respond("🎉 @here #{name} HAS GOT QUINTS! 🎉")
        end
      end
    end
  end
end
