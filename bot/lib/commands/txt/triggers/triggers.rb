# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Triggers
      extend Discordrb::Commands::CommandContainer
      command(:triggers,
              aliases: %i[listtriggers triggerlist liipaisimet liipaisinlista triggerit],
              description: "Lists user's triggers. All parameter lists all triggers.",
              usage: 'triggers <all (does not work in PMs)>',
              require_register: true) do |event, all|
        result_amount = 0
        triggers = TohsakaBot.db[:triggers]
        used_id = TohsakaBot.get_user_id(event.author.id)
        sorted = if all == 'all' && !event.channel.pm?
                   triggers.where(server_id: event.server.id.to_i).order(:id)
                 else
                   triggers.where(user_id: used_id).order(:id)
                 end

        header = '`Modes: exact (0), any (1) and regex (2). '.dup
        output = "`  ID | M & % | TRIGGER                           | MSG/FILE`\n".dup
        sorted.each do |t|
          chance = TohsakaBot.trigger_data.parse_chance(t[:chance], t[:mode])

          output << if t[:reply].nil? || t[:reply].length.zero?
                      "`#{format('%4s', t[:id])} |"\
                      " #{format('%-5s', "#{t[:mode]} & #{chance}")} |"\
                      " #{format('%-33s', t[:phrase].to_s.gsub("\n", '')[0..30])} |"\
                      " #{format('%-21s', t[:file][0..20])}`\n"
                    else
                      "`#{format('%4s', t[:id])} |"\
                      " #{format('%-5s', "#{t[:mode]} #{chance}")} |"\
                      " #{format('%-33s', t[:phrase].to_s.gsub("\n", '')[0..30])} |"\
                      " #{format('%-21s', t[:reply].gsub("\n", '')[0..20])}`\n"
                    end
          result_amount += 1
        end

        where = result_amount > 5 ? event.author.pm : event.channel

        msgs = []
        if result_amount.positive?
          header << "#{result_amount} trigger#{'s' if result_amount > 1} found.`\n"
          header << output
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(header), where)
        else
          msgs << event.respond('No triggers found.')
        end

        TohsakaBot.expire_msg(where, msgs, event.message)
        break
      end
    end
  end
end
