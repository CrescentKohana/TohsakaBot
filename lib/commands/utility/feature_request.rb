module TohsakaBot
  module Commands
    module FeatureRequest
      extend Discordrb::Commands::CommandContainer
      command(:featurerequest,
              aliases: %i[requestfeature fr],
              description: 'Takes an idea and saves it to file.',
              usage: "Use 'triggeradd <feature or idea>",
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, *msg|

        if TohsakaBot.user_limit_reached?(event.author.id, 1000, :triggers)
          event.respond "The the maximum amount of feature requests a user can have is 1000. "
          break
        end

        discord_uid = event.message.user.id
        time = Time.parse(event.message.timestamp.to_s).to_i
        request = msg.join(' ').strip

        db = YAML::Store.new('data/feature_requests.yml')
        db.transaction do
          i = 1
          i += 1 while db.root?(i)
          db[i] = {
              "user" => discord_uid,
              "time" => time,
              "request" => request
          }
          db.commit
        end

        event.respond("Request saved.")
      end
    end
  end
end
