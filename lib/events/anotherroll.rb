module TohsakaBot
  module Events
    module AnotherRoll
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :roll, delay: 10
      extend Discordrb::EventContainer
      reaction_add(emoji: '🎲') do |event|

        # TODO: Not sure what to do with this. It works as it should but I'm still getting this error in terminal.
        # Exception: #<LocalJumpError: break from proc-closure> ✗ ...lib/events/anotherroll.rb:12:in `block in <module:AnotherRoll>'
        # 'next' does not seem to do what it needs to do (not to execute this command).
        break if !event.message.author.current_bot? || event.user.bot_account

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
          Kernel.send_embedded_roll(event, number, name, i)

          if number =~ /(\d)\1{3}/ && i == 4
            name = BOT.member(event.server, event.author.id).display_name
            Kernel.give_temporary_role(event, $settings['winner_role'])
            event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
          end
        end
      end
    end
  end
end
