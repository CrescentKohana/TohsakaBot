# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerSearch
      extend Discordrb::Commands::CommandContainer
      command(:triggersearch,
              aliases: %i[searchtrigger tsearch ts],
              description: 'Search triggers.',
              usage: "Use 'triggersearch -h|--help' for help.",
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, *msg|
        options = TohsakaBot.command_parser(
          event, msg, 'Usage: triggersearch [options]', '',
          [:id, 'ID of the trigger. Ignores other options when used.', { type: :integer }],
          [:author, 'Creator of the trigger. Format: Discord ID or mention', { type: :string }],
          [:phrase, 'Phrase from which the bot triggers.', { type: :strings }],
          [:reply, 'Reply to the phrase.', { type: :strings }]
        )
        break if options.nil?

        triggers = TohsakaBot.db[:triggers]
        results = triggers.where(server_id: event.server.id.to_i).order(:id).all.select do |t|
          discord_uid = TohsakaBot.get_discord_id(t[:user_id]).to_i

          if options.id.nil?
            # If no author specified, it's ignored.
            opt_author = if options.author.nil?
                           discord_uid
                         else
                           BOT.user(TohsakaBot.discord_id_from_mention(options.author))
                         end

            # Tries to match with the given string as is, if there were no proper arguments.
            if options.author.nil? && options.phrase.nil? && options.reply.nil?

              message = msg.join(' ')
              opt_phrase = message
              opt_reply = message

              # if User matches OR Phrase is included OR Reply OR File is included
              discord_uid == opt_author &&
                (t[:phrase]&.include?(opt_phrase) || t[:reply]&.include?(opt_reply) || t[:file]&.include?(opt_reply))
            else
              opt_phrase = options.phrase.nil? ? nil : options.phrase.join(' ')
              opt_reply = options.reply.nil? ? nil : options.reply.join(' ')
              opt_phrase ||= t[:phrase]
              opt_reply ||= t[:reply]

              # if User matches AND Phrase is included AND (Reply OR File is included)
              discord_uid == opt_author &&
                t[:phrase]&.include?(opt_phrase) && (t[:reply]&.include?(opt_reply) || t[:file]&.include?(opt_reply))
            end
          else
            options.id == t[:id]
          end
        end

        result_amount = 0
        header = '`Modes: exact (0), any (1) and regex (2). '.dup
        output = "`  ID | M & % | TRIGGER                           | MSG/FILE`\n".dup
        results.each do |t|
          chance = TohsakaBot.trigger_data.parse_chance(t[:chance], t[:mode])
          output << if t[:reply].blank?
                      "`#{format('%4s', t[:id])} |"\
                      " #{format('%-5s', "#{t[:mode]} & #{chance}")} |"\
                      " #{format('%-33s', t[:phrase].to_s.gsub("\n", '')[0..30])} |"\
                      " #{format('%-21s', t[:file][0..20])}`\n"
                    else
                      "`#{format('%4s', t[:id])} |"\
                      " #{format('%-5s', "#{t[:mode]} & #{chance}")} |"\
                      " #{format('%-33s', t[:phrase].to_s.gsub("\n", '')[0..30])} |"\
                      " #{format('%-21s', t[:reply].gsub("\n", '')[0..20])}`\n"
                    end
          result_amount += 1
        end

        where = result_amount > 5 ? event.author.pm : event.channel

        if result_amount.positive?
          header << "#{result_amount} trigger#{'s' if results.length > 1} found.`\n"
          header << output
          where.split_send header.to_s
        else
          event.<< 'No triggers found.'
        end
      end
    end
  end
end
