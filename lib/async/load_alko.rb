module TohsakaBot
  module Async
    module LoadAlko
      Thread.new do
        url = "https://www.alko.fi/INTERSHOP/static/WFS/Alko-OnlineShop-Site/-/Alko-OnlineShop/" +
            "fi_FI/Alkon%20Hinnasto%20Tekstitiedostona/alkon-hinnasto-tekstitiedostona.xlsx"

        temp_file = 'tmp/alko_temp.xlsx'

        loop do
          # If the file was created less than 24 hours ago, do nothing.
          if !File.exist?(temp_file) || (File.new(temp_file).birthtime.to_i + 86400) <= Time.now.to_i
            new_file = "tmp/alko_temp#{Time.now.to_i}.xlsx"
            IO.copy_stream(URI.open(url), new_file)

            if File.exist?(temp_file) && FileUtils.identical?(new_file, temp_file)
              File.delete(new_file)
              puts "No update needed for data/alko.csv."
            else
              File.rename(new_file, temp_file)

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
          end
          sleep(86400)
        end
      end
    end
  end
end
