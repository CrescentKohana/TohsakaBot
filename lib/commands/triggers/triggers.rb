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
        output = "`  ID | TRIGGER               | MSG/FILE"
        pos = 0

        if all_triggers == "all"
          author_id = /.*/
          where = event.author.pm
        else
          author_id = event.author.id.to_s.to_regexp(detect: true)
          where = event.channel
        end

        sorted = triggers.sort_by { |k| k }
        sorted.each do |key, value|
          if (value["user"].to_s =~ author_id) == 0
            current_triggers << [key, value["trigger"].to_s, value["reply"].to_s, value["file"].to_s, value["user"]]
            if current_triggers[pos][2].empty?
              output << "`#{sprintf("%4s", current_triggers[pos][0])} | #{sprintf("%-21s", current_triggers[pos][1][0..15])} | #{current_triggers[pos][3][9..-1][0..40]}`\n"
            else
              output << "`#{sprintf("%4s", current_triggers[pos][0])} | #{sprintf("%-21s", current_triggers[pos][1][0..15])} | #{current_triggers[pos][2].lines.first.chomp[0..40]}`\n"
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
