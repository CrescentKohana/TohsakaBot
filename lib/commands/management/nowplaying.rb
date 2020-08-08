module TohsakaBot
  module Commands
    module NowPlaying
      extend Discordrb::Commands::CommandContainer
      command(:nowplaying,
              aliases: %i[np],
              description: 'Now playing status.',
              usage: 'np <twitch url for streaming status> <status>',
              min_args: 1,
              allowed_roles: [299992716480348160, 501795427797041162]) do |event, *m|

        np = m.join(' ').to_s
        cfg = YAML.load_file('cfg/config.yml')
        BOT.game = cfg['np'] = np
        File.open('cfg/config.yml', 'w') { |f| f.write cfg.to_yaml }
        event.respond("Status changed to #{np.strip_mass_mentions}")
      end
    end
  end
end
