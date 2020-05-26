module TohsakaBot
  class FirstTimeSetup
    def initialize
    end

    def create_data_files_and_configs
      # TODO: Make sure that they work with a clean install!
      puts "Creating files..."
      File.open("cfg/auth.yml", "w") do |f|
        print "Type in the owner ID (your Discord user ID): "
        owner_id = gets
        print "Type in the client ID (found in the main category of your app): "
        cli_id = gets
        print "Type in the bot token (found in the bot category of your app): "
        bot_token = gets
        print "Type in a the MySQL/MariaDB user name: "
        db_user = gets
        print "Type in a the MySQL/MariaDB password: "
        db_password = gets

        # TODO: Disable the functionality of YT and SauceNao commands/events if not set.
        print "Type in an YouTube API key (optional): "
        yt_apikey = gets
        print "Type in a SauceNao API key (optional): "
        saucenao_apikey = gets

        f.write("# Personal keys, IDs and tokens\n\n" +
                    "owner_id: \"#{owner_id}\"\n" +
                    "bot_token: \"#{bot_token}\"\n" +
                    "cli_id: \"#{cli_id}\"\n" +
                    "yt_apikey: \"#{yt_apikey}\"\n" +
                    "saucenao_apikey: \"#{saucenao_apikey}\"\n\n" +
                    "# Internal auth\n" +
                    "db_user: \"#{db_user}\"\n" +
                    "db_password: \"#{db_password}\"\n" +
                    "db_name: \"tohsaka\"\n" +
                    "db_url: \"localhost\" \n" +
                    "# DO NOT SHARE THIS FILE OR ITS CONTENTS WITH ANYONE\n")
      end

      File.open("cfg/config.yml", "w") do |f|
        prefix = "?"
        now_playing = "TohsakaBot"

        print "Type in the preferred command prefix (default is ?): "
        prefix = gets unless gets.nil?

        print "Type in the default channel ID: "
        channel_id = gets

        f.write("---\n" + "prefix: \"#{prefix}\"\n" +
                    "np: \"#{now_playing}\"" +
                    "default_channel: \"#{channel_id}\"" +
                    "remainder_limit: \"50\"\n" +
                    "trigger_limit: \"10\"\n" +
                    "temp_folder: \"tmp\"\n" +
                    "default_trigger_chance: \"2\"\n\n" +
                    "winner_role: \"0000\"\n\n" +
                    "loser_role: \"0000\"\n\n" +
                    "url_regex: \"2\"\n\n")
      end

      File.open("data/excluded_urls.yml", "w") { |f| f.write("---") } unless File.exist?('data/excluded_urls.yml')

      File.open("data/repost.yml", "w") { |f| f.write("---") } unless File.exist?('data/repost.yml')

      File.open("data/temporary_roles.yml", "w") { |f| f.write("---") } unless File.exist?('data/temporary_roles.yml')

      puts "Necessary files created!"
    end

    def welcome_message

    end
  end
end
