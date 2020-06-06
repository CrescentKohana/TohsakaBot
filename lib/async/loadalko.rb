module TohsakaBot
  module Async
    module LoadAlko
      Thread.new do
        url = "https://www.alko.fi/INTERSHOP/static/WFS/Alko-OnlineShop-Site/-/Alko-OnlineShop/" +
            "fi_FI/Alkon%20Hinnasto%20Tekstitiedostona/alkon-hinnasto-tekstitiedostona.xlsx"

        temp_file = 'tmp/alko_temp.xlsx'

        loop do
          file_name = "tmp/alko_temp#{Time.now.to_i}.xlsx"
          IO.copy_stream(URI.open(url), file_name)

          if File.exist?(temp_file) && FileUtils.identical?(file_name, temp_file)
            File.delete(file_name)
            puts "No update needed for data/alko.csv."
          else
            File.rename(file_name, temp_file)

            sheet = Roo::Spreadsheet.open(temp_file)
            sheet.to_csv('tmp/alko_temp.csv')

            # Remove unnecessary lines from the CSV
            dest = File.open('data/alko.csv','w')
            File.open('tmp/alko_temp.csv', 'r').each_with_index do |line, i|
              next if i == 0 || i == 1 || i == 2
              dest.write(line)
            end
            dest.close
            File.delete('tmp/alko_temp.csv')

            puts "Alko's alcohol database loaded into data/alko.csv."
          end
          sleep(86400)
        end
      end
    end
  end
end
