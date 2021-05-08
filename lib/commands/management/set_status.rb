# frozen_string_literal: true

module TohsakaBot
  module Commands
    module SetStatus
      extend Discordrb::Commands::CommandContainer
      command(:setstatus,
              aliases: %i[np],
              description: 'Now playing status.',
              usage: 'np <type (playing, watching, listening, competing)> <status>',
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["set_status"]) do |event, type, *msg|
        msg = msg.join(' ')
        type = "playing" unless %w[playing watching listening streaming competing].include?(type)

        TohsakaBot.status(type, msg)
        cfg = YAML.load_file("cfg/config.yml")
        cfg["status"] = [type, msg]

        File.open('cfg/config.yml', 'w') { |f| f.write cfg.to_yaml }
        event.respond("Status changed to `#{msg.strip_mass_mentions}` as `#{type}`.")
      end
    end
  end
end
