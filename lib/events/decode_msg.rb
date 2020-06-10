module TohsakaBot
  module Events
    module DecodeMsg
      extend Discordrb::EventContainer
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :decoder, delay: 10
      reaction_add(emoji: '🔓') do |event|
        next if rate_limiter.rate_limited?(:decoder, event.user)

        msg = event.message

        if msg.to_s.match(/\?rot13?.*|\?spoilers?.*|\?rotta13.*/i) || msg.to_s[0] == "\u2063"
          msguser = event.message.user
          # nickname = BOT.member(event.server, msguser.id.to_i).nick
          msg.content.slice!(/\?rot13?|\?spoilers?|\?rotta13/i)
          decoded = msg.content.tr('n-za-mN-ZA-M', 'a-zA-Z')

          if decoded.size > 1016
            break
            # decodedsplit = decoded.partition(/.{#{decoded.size / 2}}/)[1, 2]
          end

          event.user.pm.send_embed do |embed|
            embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: msguser.distinct, icon_url: msguser.avatar_url)
            embed.colour = 0xA82727
            embed.timestamp = event.message.timestamp
            embed.add_field(name: 'Content:', value: decoded)
          end
        end
      end
    end
  end
end
