module TohsakaBot
  module Commands
    module TagFeatureRequest
      extend Discordrb::Commands::CommandContainer
      command(:tagfeaturerequest,
              aliases: %i[tagfr],
              description: 'Tags a feature request. Currently all tags (new, indev, done, wontdo) are exclusive from each other.',
              usage: "Use 'fr <tags (new, indev, done, wontdo)>'",
              min_args: 2,
              require_register: true,
              permission_level: 1000) do |event, id, *tags|

        requests = YAML.load_file('data/feature_requests.yml')

        if requests[id.to_i].nil?
          event.<< "No feature request with an ID of `#{id}` found."
        else
          requests[id.to_i]['tags'] = tags.join(' ')
          File.open('data/feature_requests.yml', 'w') do |h|
            h.write requests.to_yaml
          end
          event.<< "Feature request `#{id}` updated!"
        end
      end
    end
  end
end
