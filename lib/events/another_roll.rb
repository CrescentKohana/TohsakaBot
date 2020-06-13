module TohsakaBot
  module Events
    module AnotherRoll
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :roll, delay: 10
      extend Discordrb::EventContainer
      reaction_add(emoji: '🎲') do |event|
        unless !event.message.author.current_bot? || event.user.bot_account
          Discordrb::API::Channel.delete_user_reaction("Bot #{AUTH.bot_token}", event.channel.id, event.message.id, '🎲', event.user.id)

          next if rate_limiter.rate_limited?(:roll, event.user)

          msg = event.message.content
          user_id = event.message.author
          role_id = CFG.winner_role.to_i

          # Checks if the end of the message has
          # one or more zero-width space identifier(s).
          if msg[-1] == "\u200B"
            case msg
            when /.*\u200B\u200B\u200B\u200B\u200B/i
              number = rand(0..99999)
              i = 5
            when /.*\u200B\u200B\u200B\u200B/i
              number = rand(0..9999)
              i = 4
            when /.*\u200B\u200B\u200B/i
              number = rand(0..999)
              i = 3
            when /.*\u200B\u200B/i
              number = rand(0..99)
              i = 2
            else
              break
            end
            name = BOT.member(event.server, event.user.id).display_name.strip_mass_mentions.sanitize_string

            # Sends an embedded message with the rolled number and
            # the name of the user who rolled combined
            # with a link to the original message.
            event.channel.send_embed do |embed|
              embed.colour = 0x36393F
              embed.add_field(
                  name: "🎲 **#{number.to_s.rjust(i, '0')}**",
                  value: "[#{name}](https://discordapp.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})"
              )
            end

            if number.to_s =~ /(\d)\1{3}/ && i == 4
              name = BOT.member(event.server, event.author.id).display_name
              TohsakaBot.give_temporary_role(event, role_id, user_id)
              event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
            elsif number.to_s =~ /(\d)\1{4}/ && i == 5
              name = BOT.member(event.server, event.author.id).display_name
              TohsakaBot.give_temporary_role(event, role_id, user_id)
              event.respond("🎉 @here #{name} HAS GOT QUINTS! 🎉")
            end
          end
        end
      end
    end
  end
end
