module TohsakaBot
  module Events
    module Trigger
      extend Discordrb::EventContainer
      message(containing: $triggers_only) do |event|
        break if event.channel.pm?

        $triggers = YAML.load_file('data/triggers.yml')
        $triggers.each do |k, v|
          mode = v["mode"].to_i
          phrase = v["phrase"]
          match = false
          if mode == 1
            phrase = '/.*\b' + phrase.to_s + '\b.*/i'
            match = true if (event.content =~ phrase.to_regexp(detect: true)) == 0
          elsif mode == 2
            match = true if (event.content =~ phrase.to_regexp(detect: true)) == 0
          else
            match = true if event.content == phrase.to_s
          end

          if match
            chance = v["chance"].to_i
            c = chance == 0 ? $settings['default_trigger_chance'].to_i : chance.to_i
            pickup = Pickup.new({"true" => c, "false" => 100 - c})
            picked = pickup.pick(1)

            if picked == "true"
              file = v["file"]
              if file.to_s.empty?
                event.respond v['reply']
              else
                event.channel.send_file(File.open("triggers/#{file}"))
              end
            else
              break
            end
          end
        end
      end
    end
  end
end
