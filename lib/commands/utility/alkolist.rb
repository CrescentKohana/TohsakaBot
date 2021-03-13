# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Alkolist
      extend Discordrb::Commands::CommandContainer
      command(:alkolist,
              aliases: %i[alcohollist drinklist],
              description: 'Lists all the types for alko command.',
              usage: '') do |event|
        event.channel.send_embed do |e|
          e.title = 'TYPES'
          e.colour = 0xA82727
          e.timestamp = Time.now
          e.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'alko <max price in euros (integer)> <type>')

          e.add_field(
            name: 'Simple:',
            value: "oluet, rommit, konjakit, viskit, siiderit, "\
                   "juomasekoitukset, punaviinit, valkoviinit, roseeviinit, alkoholittomat"
          )
          e.add_field(
            name: 'Advanced:',
            value: "'jälkiruokaviinit, väkevöidyt ja muut viinit' \n"\
                   "'brandyt, armanjakit ja calvadosit' \n"\
                   "'ginit ja maustetut viinat' \n"\
                   "'liköörit ja katkerot' \n"\
                   "'kuohuviinit & samppanjat' \n"\
                   "'vodkat ja viinat'"
          )
          e.add_field(
            name: 'and a fuckton of aliases, a couple examples here:',
            value: 'muumimehut, kalja, likööri, viina'
          )
        end
      end
    end
  end
end
