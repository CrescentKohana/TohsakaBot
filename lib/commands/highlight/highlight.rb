module TohsakaBot
  module Commands
    module Highlight
      extend Discordrb::Commands::CommandContainer
      command(:highlight,
              aliases: %i[hl],
              description: 'Copies one or more messages to a highlights channel. ' \
                           'Pinned messages but better.',
              min_args: 1,
              usage: 'highlight <message_id> ' \
                     '<(optional, how many backtracked messages) number> ' \
                     "<(optional, Y if only OP's messages) Y/N>",
              rescue: "Something went wrong!\n`%exception%`") do |event, msg_id, num_of_msgs_before, only_op|




      end
    end
  end
end
