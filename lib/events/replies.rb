module TohsakaBot
  module Events
    module Replies
      extend Discordrb::EventContainer
      message(containing: $triggers_only) do |event|

        break if event.channel.pm?

        $triggers = YAML.load_file('data/triggers.yml')

        $triggers.each do |key, value|
          if (event.content =~ value['trigger'].to_regexp(detect: true)) == 0

            c = if value['chance'].to_s.empty?
                  $settings['default_trigger_chance'].to_i
                else
                  value['chance'].to_i
                end

            what_to_do = { 'true' => c, 'false' => 100 - c }

            pickup = Pickup.new(what_to_do)
            picked = pickup.pick(1)

            if picked == 'true'
              if value['file'].to_s.empty?
                event.respond(value['reply'])
              else
                event.channel.send_file(File.open(value['file']))
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
