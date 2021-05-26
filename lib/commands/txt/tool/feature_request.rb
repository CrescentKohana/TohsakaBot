# frozen_string_literal: true

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
        # if TohsakaBot.user_limit_reached?(event.author.id, 1000, :triggers)
        #   event.respond 'The maximum amount of feature requests a user can have is 1000. '
        #   break
        # end

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

      command(:findfeaturerequests,
              aliases: %i[findfrs findfr findfeaturerequest ffr requests frs],
              description: 'Finds and lists feature requests based on given tags.',
              usage: "ffr <tags (new, indev, done, wontdo, all)>",
              min_args: 1,
              require_register: true) do |event, *tags|
        result_amount = 0
        header = "`  ID | CREATED    | BY                               | TAGS `\n".dup
        output = ''.dup
        requests = YAML.safe_load(File.read('data/feature_requests.yml'))

        if requests
          sorted = requests.sort
          sorted.each do |id, r|
            next unless tags.any? { |tag| r['tags'].include? tag } || tags.include?('all')

            result_amount += 1
            datetime = Time.at(r['time']).to_s.split(' ')[0]
            username = BOT.user(r['user']).username
            output << "`#{format('%4s', id)} | #{datetime} |"\
                      " #{format('%-32s', username)} | #{r['tags']}`\n`\t\tREQ:` #{r['request']}\n"
          end
        end

        where = result_amount > 5 ? event.author.pm : event.channel
        msgs = []
        if result_amount.positive?
          header << output
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(header), where)
        else
          msgs << event.respond('No requests found.')
        end

        TohsakaBot.expire_msg(where, msgs, event.message)
        break
      end

      command(:tagfeaturerequest,
              aliases: %i[tagfr],
              description: 'Tags a feature request. Currently all tags (new, indev, done, wontdo) are exclusive from each other.',
              usage: "tag <id> <tag (new, indev, done, wontdo)>",
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
          BOT.channel(CFG.default_channel.to_i).send_message("Feature request `#{id}` #{username} #{msg}")
        end
      end
    end
  end
end
