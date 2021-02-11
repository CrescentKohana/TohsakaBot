module TohsakaBot
  module Events
    module MessageIDCheck
      extend Discordrb::EventContainer
      message do |event|
        id = event.message.id
        first, second = /(\d)(\1*$)/.match(id.to_s).captures
        capture = first.to_s + second.to_s
        length = capture.length

        if length > 1
          map = {
            2 => 'doubles',
            3 => 'triples',
            4 => 'quads',
            5 => 'pentas',
            6 => 'hexas',
            7 => 'heptas',
            8 => 'octas',
            9 => 'enneas',
            10 => 'decas'
          }
          doubles_as_well = event.message.content.match(/^get.*|tupl.*/i)

          if (3...10) === length || (doubles_as_well && (2...10) === length)
            event.respond("You've got #{map[length]} <@#{event.message.author.id}> `#{capture}`!")
            next
          end

          if doubles_as_well
            event.respond("<@#{event.message.author.id}>, what in the wörld did you just get? `#{capture}`")
            next
          end
        end
      end
    end
  end
end
