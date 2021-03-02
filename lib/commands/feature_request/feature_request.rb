module TohsakaBot
  module Commands
    module FeatureRequest
      extend Discordrb::Commands::CommandContainer
      command(:featurerequest,
              aliases: %i[requestfeature fr request],
              description: 'Takes an idea and saves it.',
              usage: "Use 'fr <feature or idea>'",
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, *msg|

        if TohsakaBot.user_limit_reached?(event.author.id, 1000, :triggers)
          event.respond 'The maximum amount of feature requests a user can have is 1000. '
          break
        end

        discord_uid = event.message.user.id
        time = Time.parse(event.message.timestamp.to_s).to_i
        request = msg.join(' ').strip

        db = YAML::Store.new('data/feature_requests.yml')
        i = 1
        db.transaction do
          i += 1 while db.root?(i)
          db[i] = {
            'tags' => 'new',
            'user' => discord_uid,
            'time' => time,
            'request' => request
          }
          db.commit
        end

        event.respond("Request saved `<ID: #{i}>`.")
      end
    end
  end
end
