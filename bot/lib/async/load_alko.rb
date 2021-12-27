# frozen_string_literal: true

module TohsakaBot
  module Async
    module LoadAlko
      Thread.new do
        url = 'https://www.alko.fi/INTERSHOP/static/WFS/Alko-OnlineShop-Site/-/Alko-OnlineShop/'\
              'fi_FI/Alkon%20Hinnasto%20Tekstitiedostona/alkon-hinnasto-tekstitiedostona.xlsx'

        temp_file = 'tmp/alko_temp.xlsx'

        loop do
          # If the file was created less than 24 hours ago, do nothing.
          if !File.exist?(temp_file) || (File.new(temp_file).birthtime.to_i + 86_400) <= Time.now.to_i
            new_file = "tmp/alko_temp#{Time.now.to_i}.xlsx"
            IO.copy_stream(URI.open(url), new_file)

            if File.exist?(temp_file) && FileUtils.identical?(new_file, temp_file)
              File.delete(new_file)
              puts I18n.t(:'async.load_alko.no_update_needed')
            else
              File.rename(new_file, temp_file)

              sheet = Roo::Spreadsheet.open(temp_file)
              sheet.to_csv('tmp/alko_temp.csv')

              # Remove unnecessary lines from the CSV
              dest = File.open('data/alko.csv', 'w')
              File.open('tmp/alko_temp.csv', 'r').each_with_index do |line, i|
                next if [0, 1, 2].include?(i.to_i)

                dest.write(line)
              end
              dest.close
              File.delete('tmp/alko_temp.csv')

              puts I18n.t(:'async.load_alko.ready')
            end
          end
          sleep(86_400)
        end
      end
    end
  end
end
