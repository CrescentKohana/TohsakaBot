# frozen_string_literal: true

module TohsakaBot
  module Events
    module AnotherRoll
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :roll, delay: 10
      extend Discordrb::EventContainer
      reaction_add(emoji: '🎲') do |event|
        unless !event.message.author.current_bot? || event.user.bot_account
          Discordrb::API::Channel.delete_user_reaction(
            "Bot #{AUTH.bot_token}",
            event.channel.id, event.message.id,
            '🎲',
            event.user.id
          )

          next if rate_limiter.rate_limited?(:roll, event.user)

          msg = event.message.content
          user_id = event.user.id.to_i
          role_id = CFG.lord_role.to_i

          # Checks if the end of the message has
          # one or more zero-width space identifier(s).
          if msg[-1] == "\u200B"
            case msg
            when /.*\u200B\u200B\u200B\u200B\u200B/i
              number = rand(0..99_999).to_s
              i = 5
            when /.*\u200B\u200B\u200B\u200B/i
              number = rand(0..9999).to_s
              i = 4
            when /.*\u200B\u200B\u200B/i
              number = rand(0..999).to_s
              i = 3
            when /.*\u200B\u200B/i
              number = rand(0..99).to_s
              i = 2
            else
              break
            end
            name = BOT.member(event.server, user_id).display_name.strip_mass_mentions.sanitize_string
            event.respond("🎲 **#{number.rjust(i, '0')}** `#{name}`", false, nil, nil, false, event.message.referenced_message)

            if /(\d)\1{3}/.match?(number) && i == 4
              name = BOT.member(event.server, event.author.id).display_name
              TohsakaBot.give_temporary_role(event, role_id, user_id, 7, "Quads")
              event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
            elsif /(\d)\1{4}/.match?(number) && i == 5
              name = BOT.member(event.server, event.author.id).display_name
              TohsakaBot.give_temporary_role(event, role_id, user_id, 7, "Quints")
              event.respond("🎉 @here #{name} HAS GOT QUINTS! 🎉")
            end
          end
        end
      end
    end
  end
end
