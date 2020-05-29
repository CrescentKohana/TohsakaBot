module TohsakaBot
  module Commands
    module TriggerSearch
      extend Discordrb::Commands::CommandContainer
      command(:triggersearch,
              aliases: %i[searchtrigger tsearch ts],
              description: 'Search triggers.',
              usage: 'triggersearch --t(rigger) <trigger msg> --a(uthor) <id|mention> --r(esponse) <response msg>',
              min_args: 1,
              require_register: true,
              rescue: "`%exception%`") do |event, *msg|

        args = msg.join(' ')
        options = {}

        OptionParser.new do |opts|
          opts.on('--author USER_ID', String)
          opts.on('--trigger PHRASE', String)
          opts.on('--response RESPONSE', String)
        end.parse!(Shellwords.shellsplit(args), into: options)

        triggers = TohsakaBot.db[:triggers]
        result = triggers.where(:server_id => event.server.id.to_i).order(:id).map{ |t| t.values}.select do |t|
          phrase = t[1].to_s
          reply = t[2].to_s
          file = t[3].to_s
          discord_uid = TohsakaBot.get_discord_id(t[4]).to_i

          if options[:author].nil?
            opt_author = discord_uid
          elsif !Integer(options[:author], exception: false)
            opt_author = options[:author].gsub(/[^\d]/, '').to_i
          else
            opt_author = options[:author].to_i
          end

          # Queries with the given string as is, if there were no proper arguments
          if options[:author].nil? && options[:trigger].nil? && options[:response].nil?
            opt_trigger = args.to_s
            opt_response = args.to_s

            # if User matches OR Phrase is included OR Reply OR File is included
            discord_uid == opt_author &&
                (phrase.include?(opt_trigger) || reply.include?(opt_response) || file.include?(opt_response))
          else
            opt_trigger = options[:trigger] || phrase
            opt_response = options[:response]  || reply

            # if User matches AND Phrase is included AND (Reply OR File is included)
            discord_uid == opt_author &&
                phrase.include?(opt_trigger) && (reply.include?(opt_response) || file.include?(opt_response))
          end
        end

        result_amount = 0
        output = "`Modes include normal (0), any (1) and regex (2).`\n`  ID | M & % | TRIGGER                           | MSG/FILE`\n"
        result.each do |t|
          id = t[0]
          phrase = t[1]
          reply = t[2]
          file = t[3]
          chance = t[6]
          mode = t[7]

          if reply.nil? || reply.empty?
            output << "`#{sprintf("%4s", id)} | #{sprintf("%-5s", mode.to_s + " " + chance.to_s)} | #{sprintf("%-33s", phrase.to_s.gsub("\n", '')[0..30])} | #{sprintf("%-21s", file[0..20])}`\n"
          else
            output << "`#{sprintf("%4s", id)} | #{sprintf("%-5s", mode.to_s + " " + chance.to_s)} | #{sprintf("%-33s", phrase.to_s.gsub("\n", '')[0..30])} | #{sprintf("%-21s", reply.gsub("\n", '')[0..20])}`\n"
          end
          result_amount += 1
        end

        where = result_amount > 5 ? event.author.pm : event.channel

        if result.any?
          where.split_send "#{output}"
        else
          event.<< 'No triggers found.'
        end
      end
    end
  end
end
