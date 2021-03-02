require 'io/console'

module TohsakaBot
  class FirstTimeSetup
    def initialize; end

    def create_data_files_and_configs
      puts 'Creating files...'
      Dir.mkdir('cfg') unless File.directory?('cfg')
      File.open('cfg/auth.yml', 'w') do |f|
        print 'Type in the owner ID (your Discord user ID): '
        owner_id = gets
        print 'Type in the client ID (found here https://discord.com/developers/applications in the General Information tab of the app): '
        cli_id = gets
        print 'Type in the bot token (found on the same page in the Bot tab of the app): '
        bot_token = STDIN.noecho(&:gets).chomp

        print "\nType in a the MariaDB/MySQL username: "
        db_user = gets
        print 'Type in a the MariaDB/MySQL password: '
        db_password = STDIN.noecho(&:gets).chomp

        # TODO: Disable the functionality of YT and SauceNao commands/events if not set.
        print "\nType in an YouTube API key (Optional): "
        yt_apikey = STDIN.noecho(&:gets).chomp
        print "\nType in a SauceNao API key (Optional): "
        saucenao_apikey = STDIN.noecho(&:gets).chomp

        f.write(
          "# Personal keys, IDs and tokens\n\n"\
          "owner_id: \"#{owner_id}\"\n"\
          "bot_token: \"#{bot_token}\"\n"\
          "cli_id: \"#{cli_id}\"\n"\
          "yt_apikey: \"#{yt_apikey}\"\n"\
          "saucenao_apikey: \"#{saucenao_apikey}\"\n\n"\
          "# Internal auth\n"\
          "db_user: \"#{db_user}\"\n"\
          "db_password: \"#{db_password}\"\n"\
          "db_name: \"tohsaka\"\n"\
          "db_url: \"localhost\" \n"\
          "# DO NOT SHARE THIS FILE OR ITS CONTENTS WITH ANYONE\n"
        )
      end

      File.open('cfg/config.yml', 'w') do |f|
        prefix = '?'
        now_playing = 'TohsakaBot'

        print 'Type in the preferred command prefix (default ?): '
        prefix = gets unless gets.nil?

        print 'Type in the default channel ID: '
        default_channel = gets

        print 'Type in the highlight channel ID: '
        highlight_channel = gets

        print 'Type in the directory path of TohsakaWeb like /home/rin/www/TohsakaWeb (Optional, note for no trailing slash!): '
        web_dir = gets

        print 'Type in the ID of the lord role (basically, given to the users as a reward when they win in something): '
        lord_role = gets

        print 'Type in the ID of the fool role (basically, given to the users as a reward when they lose in something): '
        fool_role = gets

        f.write(
          "---\n"\
          "prefix: \"#{prefix}\"\n"\
          "np: \"#{now_playing}\"\n"\
          "default_channel: \"#{default_channel}\"\n"\
          "highlight_channel: \"#{highlight_channel}\"\n"\
          "web_dir: \"#{web_dir}\"\n"\
          "reminder_limit: \"100\"\n"\
          "trigger_limit: \"10\"\n"\
          "temp_folder: \"tmp\"\n"\
          "default_trigger_chance: \"5\"\n"\
          "del_trigger:\n"\
          "- not now rin\n"\
          "- no\n"\
          "lord_role: #{lord_role}\n"\
          "fool_role: #{fool_role}\n"\
          "daily_neko: false\n"
        )
      end

      File.open('data/ask_rin_answers.csv', 'w') do |f|
        f.write(
          "Yes.\t0\n"\
          "No.\t0\n"\
          "I don't know.\t0\n"\
          "Not sure.\t0\n"\
          "Impossible!\t0\n"\
          "No.\t0\n"
        )
      end

      # File.open("data/excluded_urls.yml", "w") { |f| f.write("---") } unless File.exist?('data/excluded_urls.yml')
      File.open('data/repost.yml', 'w') { |f| f.write('---') } unless File.exist?('data/repost.yml')
      File.open('data/temporary_roles.yml', 'w') { |f| f.write('--- {}') } unless File.exist?('data/temporary_roles.yml')

      Dir.mkdir('data/triggers') unless File.directory?('data/triggers')

      puts 'Necessary directories and files created!'
    end
  end
end
