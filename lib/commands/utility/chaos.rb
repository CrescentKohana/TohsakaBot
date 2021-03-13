# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Chaos
      extend Discordrb::Commands::CommandContainer
      command(:chaos,
              aliases: %i[CHAOS mock MOCK],
              description: 'cHaOs mEsSaGe',
              usage: 'chaos <msg>',
              min_args: 1) do |event, *msg|
        ch_msg = msg.join(' ').strip_mass_mentions.gsub(/(?!^)..?/, &:capitalize)
        ch_msg[0] = ch_msg[0].downcase
        uid = event.message.user.id
        event.<< "<@#{uid.to_i}>: #{ch_msg}"
        event.message.delete
      end
    end
  end
end
