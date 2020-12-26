module TohsakaBot
  module Commands
    module IcecubeMachine
      extend Discordrb::Commands::CommandContainer
      bucket :icecube, limit: 1, time_span: 60, delay: 1
      command(:icecubes,
              aliases: %i[🧊 icecubemachine icecubes icecube ic jääpalakone jääpala jääpalat],
              description: 'Timer by simulating melting icecubes.',
              usage: "Use 'icecube <how many (<= 300)> <[D]iscord | [u]nicode>",
              bucket: :icecube,
              rate_limit_message: "No cubes for you! Wait %time%s.") do |event, icecube_count, type|

        event.message.delete

        icecube_count = "1" if icecube_count.nil?

        if /\A\d+\z/.match(icecube_count)
          icecube_count = icecube_count.to_i
        else
          event.respond("Have water instead 💧")
          break
        end

        icecube_count = 300 if icecube_count > 300

        if icecube_count > 100 || (!type.nil? && (type.downcase == "unicode" || type.downcase == "u"))
          cube = "\\🧊"
          water = "\\💧"
          # steam = "\\☁"
        else
          cube = "🧊"
          water = "💧"
          # steam = "☁"
        end

        cube_array = Array.new(icecube_count, cube)
        iterations = 0

        timer_msg = event.respond("\n`#{10 * iterations}s ⏲ #{event.author.display_name}`")
        ice_msg = event.respond(cube_array.join.to_str)

        while cube_array.include? cube do
          iterations += 1

          cube_array.collect! { |e|
            if e == cube
              (Random.new.rand(1..10) > 5) ? water : e
            # elsif e == water
            #   (Random.new.rand(1..10) == 1) ? steam : e
            else
              e
            end
          }

          melted = cube_array.count { |e| e == water }

          sleep(10)
          timer_msg.edit("\n`#{melted}/#{icecube_count} 🧊 melted in #{10 * iterations}s ⏲ #{event.author.display_name}`")
          ice_msg.edit(cube_array.join.to_str)
        end

        sleep(60)
        timer_msg.delete
        ice_msg.delete
        break
      end
    end
  end
end
