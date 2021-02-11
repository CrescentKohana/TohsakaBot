module TohsakaBot
  module Events
    module MessageIDCheck
      extend Discordrb::EventContainer
      message do |event|
        next if event.channel.pm? || event.user.bot_account

        id = event.message.id
        first, second = /(\d)(\1*$)/.match(id.to_s).captures
        capture = first.to_s + second.to_s
        length = capture.length

        if length > 1
          map = {
            2 => 'Doubles',
            3 => 'Triples',
            4 => 'Quads',
            5 => 'Pentas',
            6 => 'Hexas',
            7 => 'Heptas',
            8 => 'Octas',
            9 => 'Enneas',
            10 => 'Decas'
          }
          doubles_as_well = event.message.content.match(/^get.*|tupl.*/i)
          name = BOT.member(event.server, event.message.author.id).display_name.strip_mass_mentions.sanitize_string

          if (3...10) === length || (doubles_as_well && (2...10) === length)
            event.channel.send_embed do |embed|
              embed.colour = 0x36393F
              embed.add_field(
                name: "#{map[length]}! 🆔 **#{capture}**",
                value: "[#{name}](https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})"
              )
            end
            next
          end

          if doubles_as_well
            event.channel.send_embed do |embed|
              embed.colour = 0x36393F
              embed.add_field(
                name: "What in the wörld did you just get? 🆔 **#{capture}**",
                value: "[#{name}](https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})"
              )
            end
            next
          end
        end
      end
    end
  end
end
