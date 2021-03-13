# frozen_string_literal: true

module TohsakaBot
  module Commands
    module FindFeatureRequests
      extend Discordrb::Commands::CommandContainer
      command(:findfeaturerequests,
              aliases: %i[findfrs findfr findfeaturerequest ffr requests frs],
              description: 'Finds and lists feature requests based on given tags.',
              usage: "Use 'ffr <tags (new, indev, done, wontdo, all)>'",
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
    end
  end
end
