module TohsakaBot
  module Commands
    module Reload
      extend Discordrb::Commands::CommandContainer
      command(:reload,
              description: 'Reloads commands and events. Thread reloading is currently not supported.',
              usage: 'reload',
              required_permissions: %i[manage_server],
              rescue: "Something went wrong!\n`%exception%`") do |event|

        next unless event.user.id.to_i == AUTH.owner_id.to_i
        TohsakaBot.load_modules(:Events, 'events/*/*', true, true)
        TohsakaBot.load_modules(:Commands, 'commands/*/*', true, true)
        #BOT.run(:async)
        #TohsakaBot.load_modules(:Async, 'async/*', false, true)
        #BOT.sync
        event.<< '**Commands and events reloaded!**'
      end
    end
  end
end
