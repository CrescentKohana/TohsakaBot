# frozen_string_literal: true

module TohsakaBot
  module Events
    module SharedEmoji
      extend Discordrb::EventContainer
      message(content: /.*:\w*:\D*/) do |event|
        just_emoji = /:\w*:/
        # dead_emoji = /\:\w*\:\D/
        emoji_names = event.message.content.scan(just_emoji)
        every_emoji = []
        i = 0
        j = 0

        # TODO: Emoji that already work should be deleted from the array. Not a huge issue though.
        # emoji_names.delete_if { |x| x[-1] != ':' }

        unless emoji_names.empty?
          until i == emoji_names.count
            every_emoji << BOT.find_emoji(emoji_names[i].to_s.tr!(':', ''))
            i += 1
          end

          until j == every_emoji.count || j == 19
            event.message.create_reaction("#{every_emoji[j].name}:#{every_emoji[j].id}")
            j += 1
          end
        end
      end
    end
  end
end
