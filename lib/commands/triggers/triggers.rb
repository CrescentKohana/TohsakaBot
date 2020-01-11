module TohsakaBot
  module Commands
    module Triggers
      extend Discordrb::Commands::CommandContainer
      command(:triggers,
              aliases: %i[listtriggers triggerlist liipaisimet liipaisinlista triggerit],
              description: "Lists user's triggers. Parameter 'all' lists all triggers.",
              usage: '',
              rescue: "Something went wrong!\n`%exception%`") do |event, all_triggers|

        triggers = YAML.load_file('data/triggers.yml')
        current_triggers = []
        output = "`Modes include Normal, Any and Regex.`\n`  ID | M & % | TRIGGER                        | MSG/FILE`\n"
        pos = 0

        if all_triggers == "all"
          author_id = /.*/
          where = event.author.pm
        else
          author_id = event.author.id.to_s.to_regexp(detect: true)
          where = event.channel
        end

        sorted = triggers.sort_by { |k| k }
        sorted.each do |k, v|
          if (v["user"].to_s =~ author_id) == 0
            current_triggers << [k, v["phrase"].to_s, v["reply"].to_s, v["file"].to_s, v["user"], v["chance"], v["mode"]]
            id = current_triggers[pos][0]
            phrase = current_triggers[pos][1][0..32]
            chance = current_triggers[pos][5].to_i == 0 ? $settings['default_trigger_chance'].to_s : current_triggers[pos][5].to_s
            filename = current_triggers[pos][3][0..20]
            reply = current_triggers[pos][2][0..16].gsub("\n", '')
            if current_triggers[pos][6] == 1
              mode = "A"
            elsif current_triggers[pos][6] == 2
              mode = "R"
            else
              mode = "N"
            end

            if current_triggers[pos][2].empty?
              output << "`#{sprintf("%4s", id)} | #{sprintf("%-5s", mode + " " + chance)} | #{sprintf("%-33s", phrase)} | #{sprintf("%-21s", filename)}`\n"
            else
              output << "`#{sprintf("%4s", id)} | #{sprintf("%-5s", mode + " " + chance)} | #{sprintf("%-33s", phrase)} | #{sprintf("%-21s", reply)}`\n"
            end
            pos += 1
          end
        end

        if current_triggers.any?
          where.split_send "#{output}"
        else
          event.<< 'No triggers found.'
        end
      end
    end
  end
end
