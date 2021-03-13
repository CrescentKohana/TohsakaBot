# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Typing
      extend Discordrb::Commands::CommandContainer
      command(:typing,
              aliases: %i[type],
              description: 'Starts typing.',
              permission_level: 1000,
              usage: 'typing <how long (minutes, default is unlimited)>') do |event, duration|
        if event.channel.pm?
          event.<< 'Not allowed in private messages.'
          break
        end

        TohsakaBot.manage_typing(event.channel, duration)
        break
      end
    end
  end
end
