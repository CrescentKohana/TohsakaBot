require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/string/filters'
require 'active_support/time_with_zone'
require 'bigdecimal'
require 'bundler/setup'
require 'cgi'
require 'chronic'
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
require 'to_regexp'
require 'uri'
require 'yaml'
require 'yaml/store'

require_relative 'methods.rb'
require_relative 'regex.rb'

module TohsakaBot

  # Global variables TODO: Clean this mess.
  $config = YAML.load_file('data/config.yml')
  $settings = YAML.load_file('data/settings.yml')
  $url_regexp = Regexp.new $settings["url_regex"].to_regexp(detect: true)
  $excluded_urls = YAML.load_file('data/excluded_urls.yml')
  $triggers = YAML.load_file('data/triggers.yml')
  $triggers_only = []
  $triggers.each do |key, value|
    $triggers_only << value["trigger"].to_regexp(detect: true)
  end

  # Events and commands used by the bot.
  require_relative 'events.rb'
  require_relative 'commands.rb'

  BOT = Discordrb::Commands::CommandBot.new(token: $config["bot_token"],
                                            client_id: $config["cli_id"],
                                            prefix: $settings["prefix"],
                                            advanced_functionality: false,
                                            fancy_log: true)

  Commands.include!
  Events.include!

  BOT.run(:async)

  require_relative 'async.rb'

  BOT.sync

  # @trigger_system = Trigger_system.new

  BOT.set_role_permission($config["owner_id"], 10)
end
