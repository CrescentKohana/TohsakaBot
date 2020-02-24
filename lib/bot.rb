require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/string/filters'
require 'active_support/time_with_zone'
require 'action_view'
require 'bigdecimal'
require 'bundler/setup'
require 'date'
require 'cgi'
require 'chronic'
require 'configatron/core'
require 'csv'
require 'discordrb'
require 'discordrb/webhooks'
require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pickup'
require 'roo'
require 'rubygems'
require 'sinatra'
require 'to_regexp'
require 'uri'
require 'yaml'
require 'yaml/store'

require_relative 'methods/kernel_methods'
# require_relative 'web/base'

module TohsakaBot
  unless File.exist?('cfg/config.yml')
    first = FirstTimeSetup()
    first.create_data_files_and_configs
  end

  # TODO: Complete this to get rid of the global variables!
  # Configuration & settings #
  AUTH = OpenStruct.new YAML.load_file('cfg/auth.yml')
  CFG = OpenStruct.new YAML.load_file('cfg/config.yml')

  # Global variables
  $config = YAML.load_file('cfg/auth.yml')
  $settings = YAML.load_file('cfg/config.yml')
  $url_regexp = Regexp.new CFG.url_regex.to_regexp(detect: true)
  $excluded_urls = YAML.load_file("data/excluded_urls.yml")
  $triggers = YAML.load_file("data/triggers.yml")
  $triggers_only = []
  $triggers.each do |key, value|
    $triggers_only << value["phrase"].to_s.to_regexp(detect: true)
  end

  # Events and commands used by the bot.
  require_relative 'events.rb'
  require_relative 'commands.rb'

  BOT = Discordrb::Commands::CommandBot.new(token: AUTH.bot_token,
                                            client_id: AUTH.cli_id,
                                            prefix: CFG.prefix,
                                            advanced_functionality: false,
                                            fancy_log: true)

  Commands.include!
  Events.include!

  BOT.run(:async)
  require_relative 'async.rb'
  BOT.sync

  # @trigger_system = Trigger_system.new
  BOT.set_role_permission(AUTH.owner_id, 10)
end
