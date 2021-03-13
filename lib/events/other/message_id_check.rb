# frozen_string_literal: true

module TohsakaBot
  module Events
    module MessageIDCheck
      extend Discordrb::EventContainer
      message do |event|
        next if event.channel.pm? || event.user.bot_account

        id = event.message.id
        first, second = /(\d)(\1*$)/.match(id.to_s).captures
        capture = first.to_s + second.to_s
        @length = capture.length
        @msg = event.message.content
        next unless @length > 1

        def self.check_pair(min_length, naming)
          @length >= min_length && @msg.match(/^get.*|#{naming}.*/i)
        end

        name = BOT.member(event.server, event.message.author.id).display_name.strip_mass_mentions.sanitize_string

        if @length > 10
          reply = "What in the wörld did you just get? 🆔 **#{capture}**"
        else
          map = {
            2 => '貳 Doubles',
            3 => '参 Triples',
            4 => '肆 Quadruples',
            5 => '伍 Quintuples',
            6 => '陸 Sextuples',
            7 => '漆 Septuples',
            8 => '捌 Octuples',
            9 => '玖 Nonuples',
            10 => '拾 Decuples'
          }

          next unless @length >= 5 || check_pair(2, "dubs") || check_pair(3, "trips") || check_pair(4, "quads")

          reply = "#{map[@length]}! 🆔 **#{capture}**"
        end

        event.channel.send_embed do |embed|
          embed.colour = 0x36393F
          embed.add_field(
            name: reply,
            value: "[#{name}](https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})"
          )
        end
      end
    end
  end
end
