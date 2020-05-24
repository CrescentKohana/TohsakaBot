module TohsakaBot
  module Async
    module LoadAlko
      Thread.new do
        url = "https://www.alko.fi/INTERSHOP/static/WFS/Alko-OnlineShop-Site/-/Alko-OnlineShop/" +
            "fi_FI/Alkon%20Hinnasto%20Tekstitiedostona/alkon-hinnasto-tekstitiedostona.xlsx"

        loop do
          # TODO: Compare with the existing file first.
          IO.copy_stream(URI.open(url), 'tmp/alko_temp.xlsx')
          sheet = Roo::Spreadsheet.open('tmp/alko_temp.xlsx')
          sheet.to_csv('tmp/alko_temp.csv')

          # Remove unnecessary lines from the CSV
          dest = File.open('data/alko.csv','w')
          File.open('tmp/alko_temp.csv', 'r').each_with_index do |line, i|
            next if i == 0 || i == 1 || i == 2
            dest.write(line)
          end
          dest.close

          puts "Alko's alcohol database loaded into data/alko.csv."
          sleep(86400)
        end
      end
    end
  end
end
