# frozen_string_literal: true

module TohsakaBot
  module Events
    module SharedEmoji
      extend Discordrb::EventContainer
      message(content: /.*:\w*:\D*/) do |event|
        emoji_names = event.message.content.scan(/:\w*:/)
        next if emoji_names.empty?

        every_emoji = []
        emoji_names.each do |emoji_name|
          every_emoji << BOT.find_emoji(emoji_name.to_s.tr!(':', ''))
        end

        i = 0 # A message can have up to 20 unique reactions.
        until i == every_emoji.count || i == 20
          next if every_emoji[i].nil?

          event.message.create_reaction("#{every_emoji[i].name}:#{every_emoji[i].id}")
          i += 1
        end
      end
    end
  end
end
