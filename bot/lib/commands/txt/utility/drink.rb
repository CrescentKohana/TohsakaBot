# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Drink
      extend Discordrb::Commands::CommandContainer

      MAX_BUDGET = 500 # in euros
      command(:alko,
              description: "Recommends drinks from Alko (a Finnish alcohol store) based on budget and type.",
              usage: "alko <max price in euros (integer, <= #{MAX_BUDGET}€)> <type>",
              min_args: 2) do |event, price, *type|
        m = event.respond('Parsing data...')
        if price.to_i <= MAX_BUDGET
          aliases = YAML.safe_load(File.read("data/persistent/alko_aliases.yml"))
          aliases&.each_key do |k|
            aliases[k].each do |v|
              @output_type = k if v == type.join(" ").to_s.downcase
            end
          end

          matched = []
          csv_text = File.read("data/alko.csv")
          csv = CSV.parse(csv_text, headers: true)
          break if csv.nil?

          csv.map do |h|
            next if h["Nimi"].nil?
            next unless h["Tyyppi"].is_a?(String)

            if (BigDecimal(h["Hinta"], 0) * 100).to_i <= (price.to_f * 100).to_i && h["Tyyppi"].downcase == @output_type
              matched << h
            end
          end

          if matched.empty?
            m.delete
            event.respond "No drinks were found within the budget or the given type doesn't exist."
            break
          end

          random_recommendations = []
          (1..5).each do |i|
            random_recommendations << matched.sample(6).slice!(i)
          end

          alko_url = 'https://www.alko.fi/tuotteet/'
          sorted = random_recommendations.sort_by { |a| -(a[21].to_f / a[5].to_f) }
          event.channel.send_embed do |embed|
            embed.title = "Here's something for you to ~~get drunk~~ enjoy"
            embed.colour = 0xA82727
            embed.timestamp = Time.now
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Sorted by the amount of alcohol per €")

            embed.add_field(name: ":black_small_square: #{sorted[0][1]}",
                            value: "[#{sorted[0][3]}・#{sorted[0][21]}%・#{sorted[0][4]}€](#{alko_url}#{sorted[0][0]})")
            embed.add_field(name: ":black_small_square: #{sorted[1][1]}",
                            value: "[#{sorted[1][3]}・#{sorted[1][21]}%・#{sorted[1][4]}€](#{alko_url}#{sorted[1][0]})")
            embed.add_field(name: ":black_small_square: #{sorted[2][1]}",
                            value: "[#{sorted[2][3]}・#{sorted[2][21]}%・#{sorted[2][4]}€](#{alko_url}#{sorted[2][0]})")
            embed.add_field(name: ":black_small_square: #{sorted[3][1]}",
                            value: "[#{sorted[3][3]}・#{sorted[3][21]}%・#{sorted[3][4]}€](#{alko_url}#{sorted[3][0]})")
            embed.add_field(name: ":black_small_square: #{sorted[4][1]}",
                            value: "[#{sorted[4][3]}・#{sorted[4][21]}%・#{sorted[4][4]}€](#{alko_url}#{sorted[4][0]})")
          end
          m.edit "Data parsed in #{(Time.now - event.timestamp).truncate(2)}s"
        else
          m.delete
          event.respond("The maximum budget is #{MAX_BUDGET} euros.")
        end
      end

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
