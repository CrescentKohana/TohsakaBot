module TohsakaBot
  module Commands
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping,
              description: 'Pong.',
              usage: 'ping') do |event|

        event.respond("`Pong! Bot respond time (ping): #{Time.now - event.timestamp}s`")
      end
    end
  end
end
