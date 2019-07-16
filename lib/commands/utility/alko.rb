module TohsakaBot
  module Commands
    module Alko
      extend Discordrb::Commands::CommandContainer
      command(:alko,
              aliases: %i[drinks alcohol],
              description: 'Alcoholism.',
              usage: 'alko <max price in euros (integer)> <type>',
              min_args: 2,
              rescue: "Something went wrong!\n`%exception%`") do |event, iprice, *itype|

        if iprice.to_i <= 200
          m = event.respond('Parsing data...')

          aliases = YAML.load(File.read('data/aliases.yml'))
          aliases.keys.each do |k|
            aliases[k].each do |v|
              if v == itype.join(' ').to_s.downcase
                @output_type = k
              end
            end
          end

          csv_text = File.read('data/alko.csv')
          csv = CSV.parse(csv_text, :headers => true)
          @match = []
          csv.map do |h|
            if h['Tyyppi'].is_a?(String)
              if (BigDecimal(h['Hinta']) * 100).to_i <= (iprice.to_f * 100).to_i && h['Tyyppi'].downcase == @output_type
                @match << h
              end
            end
          end

          if @match.empty?
            m.delete
            event.respond("Sorry, I couldn't find anything within that budget or the type used was not in my db.")
            break
          end

          rnd_pr = []
          n = 0
          al = "https://www.alko.fi/tuotteet/"
          until n == 5
            rnd_pr << @match.sample(5).slice!(n)
            n += 1
          end

          rnd_p = rnd_pr.sort { |a, b| (BigDecimal(a[4]).to_i * 100) <=> (BigDecimal(b[4]).to_i * 100) }
          event.channel.send_embed do |embed|
            embed.title = "Here's something for you to ~~get drunk~~ enjoy"
            embed.colour = 0xA82727
            embed.url = ""
            embed.description = ""
            embed.timestamp = Time.now
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Sorted by the ratio of alcohol-% to price (€)')

            embed.add_field(name: ":black_small_square: #{rnd_p[0][1]} (#{rnd_p[0][3]} / #{rnd_p[0][20]}% / #{rnd_p[0][4]}€)", value: "#{al}#{rnd_p[0][0]}")
            embed.add_field(name: ":black_small_square: #{rnd_p[1][1]} (#{rnd_p[1][3]} / #{rnd_p[1][20]}% / #{rnd_p[1][4]}€)", value: "#{al}#{rnd_p[1][0]}")
            embed.add_field(name: ":black_small_square: #{rnd_p[2][1]} (#{rnd_p[2][3]} / #{rnd_p[2][20]}% / #{rnd_p[2][4]}€)", value: "#{al}#{rnd_p[2][0]}")
            embed.add_field(name: ":black_small_square: #{rnd_p[3][1]} (#{rnd_p[3][3]} / #{rnd_p[3][20]}% / #{rnd_p[3][4]}€)", value: "#{al}#{rnd_p[3][0]}")
            embed.add_field(name: ":black_small_square: #{rnd_p[4][1]} (#{rnd_p[4][3]} / #{rnd_p[4][20]}% / #{rnd_p[4][4]}€)", value: "#{al}#{rnd_p[4][0]}")
          end
          m.edit "Data parsed. It took #{Time.now - event.timestamp} seconds."
        else
          m.delete
          event.respond('The maximum budget is 200 euros.')
        end
      end
    end
  end
end