module TohsakaBot
  module Commands
    module Alkolist
      extend Discordrb::Commands::CommandContainer
      command(:alkolist,
              aliases: %i[alcohollist drinklist],
              description: 'Lists all the types for ?alko.',
              usage: '',
              rescue: "Something went wrong!\n`%exception%`") do |event|

        event.channel.send_embed() do |embed|
          embed.title = "TYPES"
          embed.colour = 0xA82727
          embed.url = ""
          embed.description = ""
          embed.timestamp = Time.now

          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "?alko <max price in euros (integer)> <type>")

          embed.add_field(name: "Simple:", value: "oluet, rommit, konjakit, viskit, siiderit, juomasekoitukset, punaviinit, valkoviinit, roseeviinit, alkoholittomat")
          embed.add_field(name: "Advanced:", value: "'jälkiruokaviinit, väkevöidyt ja muut viinit' \n'brandyt, armanjakit ja calvadosit' \n'ginit ja maustetut viinat' \n'liköörit ja katkerot' \n'kuohuviinit & samppanjat' \n'vodkat ja viinat'")
          embed.add_field(name: "and a fuckton of aliases, a couple examples here:", value: "muumimehut, kalja, likööri, viina (temp list https://pastebin.com/NumMUkt5)")
        end
      end
    end
  end
end
