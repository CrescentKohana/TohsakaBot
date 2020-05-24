# TODO: Clean requires!
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/string/filters'
require 'active_support/time_with_zone'
require 'action_view'
require 'bigdecimal'
require 'bundler/setup'
require 'drb/drb'
require 'date'
require 'cgi'
require 'chronic'
require 'configatron/core'
require 'csv'
require 'discordrb'
require 'discordrb/webhooks'
require 'json'
require 'net/http'
require 'mysql2'
require 'nokogiri'
require 'open-uri'
require 'optparse'
require 'pickup'
require 'roo'
require 'rubygems'
require 'sequel'
require 'shellwords'
require 'to_regexp'
require 'uri'
require 'yaml'
require 'yaml/store'

require_relative 'methods/discordrb_command_override'

module TohsakaBot
  unless File.exist?('cfg/config.yml')
    first = FirstTimeSetup()
    first.create_data_files_and_configs
  end

  require_relative 'methods/kernel_methods'
  require_relative 'methods/miscellaneous'
  require_relative 'data_access/database'
  require_relative 'data_access/tohsaka_bridge'
  require_relative 'data_access/trigger_data'

  # Configuration & settings #
  AUTH = OpenStruct.new YAML.load_file('cfg/auth.yml')
  CFG = OpenStruct.new YAML.load_file('cfg/config.yml')

  # Global variables TODO: Get rid of these!
  $url_regexp = Regexp.new CFG.url_regex.to_regexp(detect: true)
  $excluded_urls = YAML.load_file("data/excluded_urls.yml")

  BOT = Discordrb::Commands::CommandBot.new(token: AUTH.bot_token,
                                            client_id: AUTH.cli_id,
                                            prefix: CFG.prefix,
                                            advanced_functionality: false,
                                            fancy_log: true)

  # Events and commands used by the bot.
  load_modules(:Commands, 'commands/*/*')
  load_modules(:Events, 'events/*')

  BOT.run(:async)
  # Asynchronous threads running in cycles.
  # load_modules(:Async, 'async/*', false)
  require_relative 'async.rb'

  # Terminal tool to send messages through the bot.
  Thread.new do
    channel = CFG.default_channel

    unless CFG.default_channel.match(/\d{18}/)
      puts "No default channel set in 'cfg/config.yml'. " +
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

  BRIDGE_URI = "druby://localhost:8787"
  FRONT_OBJECT = TohsakaBridge.new
  DRb.start_service(BRIDGE_URI, FRONT_OBJECT)

  # Wait for the drb server thread to finish before exiting.
  DRb.thread.join

  # Database connection
  Thread.new do

  end

  BOT.sync

  # @trigger_system = Trigger_system.new
  BOT.set_role_permission(AUTH.owner_id, 10)
end
