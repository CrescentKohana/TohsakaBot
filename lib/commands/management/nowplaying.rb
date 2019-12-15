module TohsakaBot
  module Commands
    module NowPlaying
      extend Discordrb::Commands::CommandContainer
      command(:nowplaying,
              aliases: %i[np],
              description: 'Now playing status.',
              usage: 'np <twitch url for streaming status> <status>',
              min_args: 1,
              allowed_roles: [299992716480348160, 501795427797041162],
              rescue: "Something went wrong!\n`%exception%`") do |event, *m|

        np = m.join(' ').to_s
        BOT.game = $settings['np'] = np

        File.open('cfg/settings.yml', 'w') { |f| f.write $settings.to_yaml }
        event.respond("Status changed to #{np.strip_mass_mentions}")
      end
    end
  end
end
