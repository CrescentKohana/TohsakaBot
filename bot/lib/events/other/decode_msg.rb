# frozen_string_literal: true

require 'base64'

module TohsakaBot
  module Events
    module DecodeMsg
      extend Discordrb::EventContainer
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :decoder, delay: 10
      reaction_add(emoji: '🔓') do |event|
        next if rate_limiter.rate_limited?(:decoder, event.user)

        msg = event.message.content
        next unless msg.to_s[-1] == "\u2063"

        msg.slice!(/\?\w*\s/i)
        decoded_msg = case msg
                      when /.*\u2063\u2063/i # base64
                        msg.gsub!("\u2063")
                        Base64.decode64(msg)
                      else # rot13
                        msg.gsub!("\u2063")
                        msg.tr('n-za-mN-ZA-M', 'a-zA-Z')
                      end

        break if decoded_msg.size > 1016

        user = event.message.user
        event.user.pm.send_embed do |embed|
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: user.distinct, icon_url: user.avatar_url)
          embed.colour = 0xA82727
          embed.timestamp = event.message.timestamp
          embed.add_field(name: 'Content:', value: decoded_msg)
        end
      end
    end
  end
end
