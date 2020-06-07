module TohsakaBot
  module Commands
    module Triggers
      extend Discordrb::Commands::CommandContainer
      command(:triggers,
              aliases: %i[listtriggers triggerlist liipaisimet liipaisinlista triggerit],
              description: "Lists user's triggers.",
              usage: 'triggers',
              require_register: true,
              rescue: "%exception%") do |event|

        result_amount = 0
        triggers = TohsakaBot.db[:triggers]
        used_id = TohsakaBot.get_user_id(event.author.id)
        sorted = triggers.where(:user_id => used_id).order(:id)

        output = "`Modes include normal (0), any (1) and regex (2).`\n`  ID | M & % | TRIGGER                           | MSG/FILE`\n"
        sorted.each do |t|
          chance = t[:chance].to_i == 0 ? CFG.default_trigger_chance.to_s : t[:chance].to_s

          if t[:reply].nil? || t[:reply].length == 0
            output << "`#{sprintf("%4s", t[:id])} | #{sprintf("%-5s", t[:mode].to_s + " " + chance)} | #{sprintf("%-33s", t[:phrase].to_s.gsub("\n", '')[0..30])} | #{sprintf("%-21s", t[:file][0..20])}`\n"
          else
            output << "`#{sprintf("%4s", t[:id])} | #{sprintf("%-5s", t[:mode].to_s + " " + chance)} | #{sprintf("%-33s", t[:phrase].to_s.gsub("\n", '')[0..30])} | #{sprintf("%-21s", t[:reply].gsub("\n", '')[0..20])}`\n"
          end
          result_amount += 1
        end

        msgs = []
        if result_amount > 0
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(output), event.channel)
        else
          msgs << event.respond('No triggers found.')
        end

        TohsakaBot.expire_msg(msgs, event.message)
        break
      end
    end
  end
end
