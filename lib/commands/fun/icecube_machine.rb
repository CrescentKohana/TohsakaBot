module TohsakaBot
  module Commands
    module IcecubeMachine
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 1, time_span: 30, delay: 1
      command(:icecubes,
              aliases: %i[🧊 icecubemachine icecubes icecube ic jääpalakone jääpala jääpalat],
              description: 'Just icecubes 🧊.',
              usage: "Use 'icecube <how many (<=100)> <[D]iscord | [u]nicode>",
              bucket: :cf,
              rate_limit_message: "No cubes for you! Wait %time%s.") do |event, icecube_count, type|

        icecube_count = "1" if icecube_count.nil?

        if /\A\d+\z/.match(icecube_count)
          icecube_count = icecube_count.to_i
        else
          event.respond("Have water instead 💧")
          break
        end

        if !type.nil? && (type.downcase == "unicode" || type.downcase == "u")
          cube = "\\🧊"
          water = "\\💧"
        else
          cube = "🧊"
          water = "💧"
        end

        icecube_count = 200 if icecube_count > 200
        cube_array = Array.new(icecube_count, cube)

        msg = event.respond(cube_array.join.to_str)

        while cube_array.include? cube do
          cube_array.collect! { |e|
            if e == cube
              (Random.new.rand(1..10) > 5) ? water : e
            else
              e
            end
          }

          sleep(10)
          msg.edit(cube_array.join.to_str)
        end
        break
      end
    end
  end
end
