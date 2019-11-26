module TohsakaBot
  class FirstTimeSetup
    def initialize()
    end

    def create_data_files_and_configs
      # TODO: Make sure that they work with a clean install!
      puts "Creating files..."
      File.open("cfg/config.yml", "w") do |f|
        print "Type in the owner ID (your Discord user ID): "
        owner_id = gets
        print "Type in the client ID (found in the main category of your app): "
        cli_id = gets
        print "Type in the bot token (found in the bot category of your app): "
        bot_token = gets
        print "Type in a YouTube API key (optional): "

        # TODO: Disable the functionality of YT and SauceNao commands/events if not set.
        yt_apikey = gets
        print "Type in a SauceNao API key (optional): "
        saucenao_apikey = gets

        f.write("# Personal keys, IDs and tokens\n\n" +
                    "owner_id: \"#{owner_id}\"\n" +
                    "bot_token: \"#{bot_token}\"\n" +
                    "cli_id: \"#{cli_id}\"\n" +
                    "yt_apikey: \"#{yt_apikey}\"\n" +
                    "saucenao_apikey: \"#{saucenao_apikey}\"\n\n" +
                    "# DO NOT SHARE THIS FILE OR ITS CONTENTS WITH ANYONE")
      end

      File.open("cfg/settings.yml", "w") do |f|
        prefix = "?"
        data_path = "data"

        print "Type in the preferred command prefix (default is ?): "
        prefix = gets unless gets.nil?

        print "Type in the preferred location of data (no / at the end of the path please!): "
        data_path = gets unless gets.nil?

        f.write("---\n" + "prefix: \"#{prefix}\"\n" +
                    "data_location: \"#{data_path}\"\n" +
                    "remainder_limit: \"50\"\n" +
                    "trigger_limit: \"10\"\n" +
                    "temp_folder: \"temp\"\n" +
                    "default_trigger_chance: \"2\"\n\n" +
                    "winner_role: \"0000\"\n\n" +
                    "loser_role: \"0000\"\n\n" +
                    "url_regex: \"2\"\n\n")
      end

      File.open("data/reminders.yml", "w") { |f| f.write("---") } unless File.exist?('data/reminders.yml')

      File.open("data/excluded_urls.yml", "w") { |f| f.write("---") } unless File.exist?('data/excluded_urls.yml')

      File.open("data/repost.yml", "w") { |f| f.write("---") } unless File.exist?('data/repost.yml')

      File.open("data/temporary_roles.yml", "w") { |f| f.write("---") } unless File.exist?('data/temporary_roles.yml')

      File.open("data/triggers.yml", "w") { |f| f.write("---") } unless File.exist?('data/triggers.yml')
      puts "Necessary files created!"
    end

    def welcome_message

    end
  end
end
