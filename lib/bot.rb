require 'bundler/setup'
require 'rubygems'

# Database #
require 'sequel'
require 'mysql2'

# Discord #
require 'discordrb'
require 'discordrb/webhooks'

# File Management #
require 'csv'
require 'json'
require 'roo'
require 'yaml'
require 'yaml/store'

# Network #
require 'cgi'
require 'open-uri'
require 'net/http'
require 'public_suffix'
## Connection with TohsakaWeb ##
require 'drb/drb'

# Date & Time #
require 'chronic'
require 'date'
require 'action_view' # helpers/date_helper
require 'active_support/core_ext/numeric/time'
require 'active_support/time_with_zone'

# Misc #
require 'benchmark'
require 'to_regexp'
## Better command parsing ##
require 'optimist'
require 'shellwords'
## Custom probability for modules like Trigger ##
require 'pickup'
## Stripping markdown from strings ##
require 'redcarpet'
require 'redcarpet/render_strip'

# Override discordrb gem
require_relative 'gem_overrides/discordrb_command_override'

module TohsakaBot
  unless File.exist?('cfg/auth.yml')
    require_relative 'first_time_setup'
    setup = FirstTimeSetup.new
    setup.create_data_files_and_configs
  end

  # Helpers #
  require_relative 'helpers/core_helper'
  require_relative 'helpers/string_helper'
  require_relative 'helpers/url_helper'
  require_relative 'helpers/math_helper'
  require_relative 'helpers/discord_helper'

  # Database, Web and Permissions #
  require_relative 'data_access/database'
  require_relative 'data_access/tohsaka_bridge'
  require_relative 'data_access/trigger_data'
  require_relative 'data_access/permissions'

  # Configuration & settings #
  AUTH = OpenStruct.new YAML.load_file('cfg/auth.yml')
  CFG = OpenStruct.new YAML.load_file('cfg/config.yml')

  # Discord Bot #
  BOT = Discordrb::Commands::CommandBot.new(token: AUTH.bot_token,
                                            client_id: AUTH.cli_id,
                                            prefix: CFG.prefix,
                                            advanced_functionality: false,
                                            fancy_log: true)

  # Sets permissions, 1000 being the highest
  TohsakaBot.set_permissions
  BOT.set_user_permission(AUTH.owner_id.to_i, 1000)

  # Discord Events and Commands #
  TohsakaBot.load_modules(:Commands, 'commands/*/*')
  TohsakaBot.load_modules(:Events, 'events/*')

  # Asynchronous threads running in cycles #
  BOT.run(:async)

  # TODO: Load async threads dynamically
  # load_modules(:Async, 'async/*', false)
  require_relative 'async.rb'

  # Cleans trigger files not present in the database.
  TohsakaBot.trigger_data.clean_trigger_files

  # Terminal tool to send messages through the bot.
  Thread.new do
    channel = CFG.default_channel

    unless CFG.default_channel.match(/\d{18}/)
      puts "No default channel set in 'cfg/config.yml'. "\
           "Before sending messages through the terminal, set the channel with 'setchan <id>'"
    end

    while (user_input = gets.strip.split(" "))
      if user_input[0] == "setchan"
        channel = user_input[1]
        puts "Channel set to #{BOT.channel(channel).name} "
      elsif user_input[0][0] == "." && channel.match(/\d{18}/)
        BOT.send_message(channel, user_input.join(" ")[1..-1])
      end
    end
  end

  # Connection with TohsakaWeb #
  BRIDGE_URI = "druby://localhost:8787"
  FRONT_OBJECT = TohsakaBridge.new
  DRb.start_service(BRIDGE_URI, FRONT_OBJECT)

  # Waits for the drb server thread to finish before exiting.
  DRb.thread.join
  BOT.sync
  # @trigger_system = Trigger_system.new
end
