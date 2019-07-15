module TohsakaBot
  module Commands
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping,
              aliases: %i[marco],
              description: 'Pong.',
              usage: '',
              rescue: "Something went wrong!\n`%exception%`") do |event|

        event.respond("`Pong! Bot respond time (ping): #{Time.now - event.timestamp}s`")
        m = event.respond("Pong!")
        m.edit "`This packet wasted #{Time.now - event.timestamp}s (RTT) in the great pipe of the internet.`"
      end
    end
  end
end
