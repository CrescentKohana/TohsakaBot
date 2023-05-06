# frozen_string_literal: true

module TohsakaBot
  module Jobs
    ALKO_URL = 'https://www.alko.fi/INTERSHOP/static/WFS/Alko-OnlineShop-Site/-/Alko-OnlineShop/fi_FI/Alkon%20Hinnasto%20Tekstitiedostona/alkon-hinnasto-tekstitiedostona.xlsx'
    TEMP_FILE = 'tmp/alko_temp.xlsx'

    def self.load_alko(now)
      now = now.to_i
      # If the file was created less than 24 hours ago, skip.
      return if File.exist?(TEMP_FILE) && (File.new(TEMP_FILE).birthtime.to_i + 86_400) > now.to_i

      new_file = "tmp/alko_temp#{now.to_i}.xlsx"
      IO.copy_stream(URI.open(ALKO_URL), new_file)

      if File.exist?(TEMP_FILE) && FileUtils.identical?(new_file, TEMP_FILE)
        File.delete(new_file)
        puts I18n.t(:'async.load_alko.no_update_needed')
      else
        begin
          File.rename(new_file, TEMP_FILE)
        rescue
          puts "Could not rename #{new_file} to #{TEMP_FILE}. Possibly permission error."
          return
        end

        sheet = Roo::Spreadsheet.open(TEMP_FILE)
        sheet.to_csv('tmp/alko_temp.csv')
        sheet.close

        # Remove unnecessary lines from the CSV
        dest = File.open(CFG.data_dir + '/alko.csv', 'w')
        origin = File.open('tmp/alko_temp.csv', 'r').each_with_index do |line, i|
          next if [0, 1, 2].include?(i.to_i)

          dest.write(line)
        end
        origin.close
        dest.close
        File.delete('tmp/alko_temp.csv')

        puts I18n.t(:'async.load_alko.ready')
      end
    end
  end
end
