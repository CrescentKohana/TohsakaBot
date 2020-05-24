module TohsakaBot
  module Commands
    module Triggers
      extend Discordrb::Commands::CommandContainer
      command(:triggers,
              aliases: %i[listtriggers triggerlist liipaisimet liipaisinlista triggerit],
              description: "Lists user's triggers.",
              usage: 'triggers',
              require_register: true,
              rescue: "Something went wrong!\n`%exception%`") do |event|

        result_amount = 0
        sorted = TohsakaBot.trigger_data.full_triggers.sort_by { |k| k }
        output = "`Modes include normal (0), any (1) and regex (2).`\n`  ID | M & % | TRIGGER                           | MSG/FILE`\n"
        sorted.each do |k, v|
          if v.user.to_i == event.author.id.to_i
            chance = v.chance.to_i == 0 ? CFG.default_trigger_chance.to_s : v.chance.to_s

            if v.reply.nil?
              output << "`#{sprintf("%4s", k)} | #{sprintf("%-5s", v.mode.to_s + " " + chance)} | #{sprintf("%-33s", v.phrase.to_s.gsub("\n", '')[0..30])} | #{sprintf("%-21s", v.file[0..20])}`\n"
            else
              output << "`#{sprintf("%4s", k)} | #{sprintf("%-5s", v.mode.to_s + " " + chance)} | #{sprintf("%-33s", v.phrase.to_s.gsub("\n", '')[0..30])} | #{sprintf("%-21s", v.reply.gsub("\n", '')[0..20])}`\n"
            end
            result_amount += 1
          end
        end

        msgs = []
        if result_amount > 0
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(output), event.channel)
        else
          msgs << event.respond('No triggers found.')
        end
        TohsakaBot.expire_msg(msgs, user_msg: event.message)
      end
    end
  end
end
