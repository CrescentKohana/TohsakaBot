module TohsakaBot
  module Commands
    module TrophyRoles
      extend Discordrb::Commands::CommandContainer
      command(:trophyroles,
              aliases: %i[trophies trophy troles listtrophies],
              description: 'Lists trophy roles.',
              usage: "listroles <'all' or 'expired' to include expired roles as well>",
              enabled_in_pm: false) do |event, filter|

        result_amount = 0
        header = "`  ID | EXPIRES    | ROLE: USER                                       `\n"
        output = ""
        roles = YAML.load(File.read('data/temporary_roles.yml'))

        time_now = Time.now.to_i

        if roles
          sorted = roles.sort
          sorted.each do |id, r|

            expires =  r['time'].to_i + (r['duration'] * 24 * 60 * 60)
            role_name = BOT.server(r['server'].to_i).role(r['role'].to_i).name

            if time_now < expires || filter == 'server' || filter == 'all'
              result_amount += 1
              datetime = Time.at(expires).to_s.to_s.split(' ')[0]
              username = BOT.member(event.server, r['user']).display_name
              output << "`#{sprintf("%4s", id)} | #{datetime} | #{role_name}: #{sprintf("%-32s", username)}`\n`\t\tREASON:` #{r['reason']}\n"
            end
          end
        end

        where = result_amount > 5 ? event.author.pm : event.channel
        msgs = []
        if result_amount > 0
          header << output
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(header), where)
        else
          msgs << event.respond('No roles found.')
        end

        TohsakaBot.expire_msg(where, msgs, event.message)
        break
      end
    end
  end
end
