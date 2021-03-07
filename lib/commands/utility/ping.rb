module TohsakaBot
  module Commands
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping,
              description: 'Pong.',
              usage: 'ping') do |event|

        locale = TohsakaBot.get_locale(event.user.id)

        event.respond(
          I18n.t(:'commands.utility.ping.response', locale: locale.to_sym, time: Time.now - event.timestamp)
        )
      end
    end
  end
end
