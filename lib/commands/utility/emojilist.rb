# frozen_string_literal: true

module TohsakaBot
  module Commands
    module EmojiList
      extend Discordrb::Commands::CommandContainer
      command(:emojilist,
              aliases: %i[emoji le],
              description: 'List all the 絵文字 bot has at its disposal.',
              usage: 'emojis') do |event|
        every_emoji = BOT.emoji
        i = 0
        emoji_names = []
        until i == every_emoji.count
          if event.server != every_emoji[i].server
            emoji_names << every_emoji[i].name
          elsif event.server == every_emoji[i].server && every_emoji[i].animated
            emoji_names << every_emoji[i].name
          end
          i += 1
        end

        event.<< "```#{emoji_names.join(' ')}```"
      end
    end
  end
end
