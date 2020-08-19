module TohsakaBot
  module Commands
    module Alko
      extend Discordrb::Commands::CommandContainer
      command(:alko,
              aliases: %i[drinks alcohol],
              description: 'Recommends drinks from Alko (a Finnish alcohol store) based on budget and type.',
              usage: 'alko <max price in euros (integer, <=500€)> <type>',
              min_args: 2) do |event, price, *type|

        m = event.respond('Parsing data...')
        if price.to_i <= 500
          aliases = YAML.load(File.read('data/aliases.yml'))
          aliases.keys.each do |k|
            aliases[k].each do |v|
              if v == type.join(' ').to_s.downcase
                @output_type = k
              end
            end
          end

          matched = []
          csv_text = File.read('data/alko.csv')
          csv = CSV.parse(csv_text, :headers => true)
          csv.map do |h|
            next if h['Nimi'].nil?
            if h['Tyyppi'].is_a?(String)
              if (BigDecimal(h['Hinta']) * 100).to_i <= (price.to_f * 100).to_i && h['Tyyppi'].downcase == @output_type
                matched << h
              end
            end
          end

          if matched.empty?
            m.delete
            event.respond "No drinks were found within that budget or given type doesn't exist."
            break
          end

          random_recommendations = []
          (1..5).each do |i|
            random_recommendations << matched.sample(5).slice!(i)
          end

          alko_url = "https://www.alko.fi/tuotteet/"

          sorted = random_recommendations.sort { |a, b| (BigDecimal(a[4]).to_i * 100) <=> (BigDecimal(b[4]).to_i * 100) }
          event.channel.send_embed do |embed|
            embed.title = "Here's something for you to ~~get drunk~~ enjoy"
            embed.colour = 0xA82727
            embed.timestamp = Time.now
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Sorted by the ratio of alcohol-% to price (€)')

            embed.add_field(name: ":black_small_square: #{sorted[0][1]} (#{sorted[0][3]} / #{sorted[0][20]}% / #{sorted[0][4]}€)", value: "#{alko_url}#{sorted[0][0]}")
            embed.add_field(name: ":black_small_square: #{sorted[1][1]} (#{sorted[1][3]} / #{sorted[1][20]}% / #{sorted[1][4]}€)", value: "#{alko_url}#{sorted[1][0]}")
            embed.add_field(name: ":black_small_square: #{sorted[2][1]} (#{sorted[2][3]} / #{sorted[2][20]}% / #{sorted[2][4]}€)", value: "#{alko_url}#{sorted[2][0]}")
            embed.add_field(name: ":black_small_square: #{sorted[3][1]} (#{sorted[3][3]} / #{sorted[3][20]}% / #{sorted[3][4]}€)", value: "#{alko_url}#{sorted[3][0]}")
            embed.add_field(name: ":black_small_square: #{sorted[4][1]} (#{sorted[4][3]} / #{sorted[4][20]}% / #{sorted[4][4]}€)", value: "#{alko_url}#{sorted[4][0]}")
          end
          m.edit "Data parsed. It took #{Time.now - event.timestamp} seconds."
        else
          m.delete
          event.respond('The maximum budget is 500 euros.')
        end
      end
    end
  end
end
