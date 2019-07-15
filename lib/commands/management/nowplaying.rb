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
              rescue: "Something went wrong!\n`%exception%`") do |event, *np|

        twitch_regex = /https?:\/\/((www)?\.)?twitch\.tv\/[\S]+/i

        if np[0].match(twitch_regex)
          twitch_url, title = np.partition { |u| u.match(twitch_regex) }
          #@a_type = title[0]
          @np = title.join(' ').to_s
          BOT.stream(@np, twitch_url[0].to_s)
          $settings['np'] = [twitch_url[0].to_s, @np]
        else
          #@a_type = np[0]
          @np = np.join(' ').to_s
          BOT.game = $settings['np'] = @np
          $settings['np'] = [0, @np]
        end

        #BOT.update_status(:online, @np, twitch_url[0], 0, false, @a_type.to_i)
        File.open('data/settings.yml', 'w') { |f| f.write $settings.to_yaml }
        event.respond("Status changed to #{@np.strip_mass_mentions}")
      end
    end
  end
end