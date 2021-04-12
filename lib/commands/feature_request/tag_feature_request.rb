# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TagFeatureRequest
      extend Discordrb::Commands::CommandContainer
      command(:tagfeaturerequest,
              aliases: %i[tagfr],
              description: 'Tags a feature request. Currently all tags (new, indev, done, wontdo) are exclusive from each other.',
              usage: "Use 'fr <tag (new, indev, done, wontdo)>'",
              min_args: 2,
              require_register: true,
              permission_level: TohsakaBot.permissions.actions["feature_requests"]) do |event, id, tag|
        requests = YAML.load_file('data/feature_requests.yml')

        if requests[id.to_i].nil?
          event.<< "No feature request with an ID of `#{id}` found."
        else
          msg = case tag
                when "done"
                  "is done!\n`#{requests[id.to_i]['request']}`"
                when "indev"
                  "is in development!\n`#{requests[id.to_i]['request']}`"
                when "wontdo"
                  "was declined: `#{requests[id.to_i]['request']}`"
                else
                  break
                end
          break if msg.nil?

          requests[id.to_i]['tags'] = tag
          File.open('data/feature_requests.yml', 'w') { |h| h.write requests.to_yaml }
          event.<< "Feature request `#{id}` updated!" unless event.channel.id.to_i == CFG.default_channel.to_i

          username = "by <@!#{requests[id.to_i]['user']}>"
          BOT.channel(CFG.default_channel.to_i).send("Feature request `#{id}` #{username} #{msg}")
        end
      end
    end
  end
end
