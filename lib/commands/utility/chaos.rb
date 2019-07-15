module TohsakaBot
  module Commands
    module Chaos
      extend Discordrb::Commands::CommandContainer
      command(:chaos,
              aliases: %i[CHAOS],
              description: 'cHaOs mEsSaGe',
              usage: 'chaos <msg>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|

        ch_msg = msg.join(' ').strip_mass_mentions.gsub /(?!^)..?/, &:capitalize
        uid = event.message.user.id
        event.<< "<@#{uid.to_i}>: #{ch_msg}"
        event.message.delete
      end
    end
  end
end