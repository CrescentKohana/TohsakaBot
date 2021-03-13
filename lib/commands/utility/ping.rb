module TohsakaBot
  module Commands
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping,
              description: I18n.t(:'commands.utility.ping.description'),
              usage: I18n.t(:'commands.utility.ping.usage')) do |event|

        now = Time.now
        locale = TohsakaBot.get_locale(event.user.id)
        event.respond(
          I18n.t(
            :'commands.utility.ping.response',
            locale: locale.to_sym,
            time: ((now - event.timestamp) * 1000).truncate
          )
        )
      end
    end
  end
end
