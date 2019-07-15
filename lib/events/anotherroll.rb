module TohsakaBot
  module Events
    module AnotherRoll
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :roll, delay: 10
      extend Discordrb::EventContainer
      reaction_add(emoji: '🎲') do |event|
        Discordrb::API::Channel.delete_user_reaction("Bot #{$config['bot_token']}", event.channel.id, event.message.id, '🎲', event.user.id)
        next if rate_limiter.rate_limited?(:roll, event.user)

        msg = event.message.content

        # Checks if the end of the message has
        # one or more zero-width space identifier(s).
        if msg[-1] == "\u200B"
          case msg
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
          # Hardcoded channel for rolls. TODO: Change this.
          # roll_channel = BOT.channel(516348014990852106)
          Kernel.send_embedded_roll(event, number, name, i)

          if number =~ /(\d)\1{3}/ && i == 4
            name = BOT.member(event.server, event.author.id).display_name

            # Adds the Winner role to the user.
            we_have_a_winner(event)

            event.respond "🎉 @here #{name} HAS GOT QUADS! 🎉"
          end
        end
      end
    end
  end
end
