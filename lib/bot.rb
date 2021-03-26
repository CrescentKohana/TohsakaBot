# frozen_string_literal: true

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
require 'http'
## Connection with TohsakaWeb ##
require 'drb/drb'

# Date & Time #
require 'chronic'
require 'date'
require 'action_view' # helpers/date_helper
require 'active_support/core_ext/numeric/time'
require 'active_support/time_with_zone'

# Localization #
require 'i18n'
require "i18n/backend/fallbacks"

# Misc #
require 'nekos'
require 'digest/sha1'
require 'benchmark'
require 'to_regexp'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string'
## Better command parsing ##
require 'optimist'
require 'shellwords'
## Custom probability for modules like Trigger ##
require 'pickup'
## Stripping markdown from strings ##
require 'redcarpet'
require 'redcarpet/render_strip'

# Override discordrb gem
# require_relative 'gem_overrides/bot_override'
require_relative 'gem_overrides/discordrb_command_override'
require_relative 'gem_overrides/cache_overrride'
# require_relative 'gem_overrides/channels_override'
# require_relative 'gem_overrides/container_override'

# Main module of the bot
module TohsakaBot
  # Localization with fallbacks
  I18n::Backend::Simple.include I18n::Backend::Fallbacks
  I18n.load_path << Dir["#{File.expand_path('locales')}/*.yml"]
  I18n.fallbacks.map(fi: :en, ja: :en)

  # Configuration & settings #
  AUTH = OpenStruct.new YAML.load_file('cfg/auth.yml')
  CFG = OpenStruct.new YAML.load_file('cfg/config.yml')

  I18n.default_locale = CFG.locale.to_sym unless CFG.locale.blank?

  # Helpers #
  require_relative 'helpers/core_helper'
  require_relative 'helpers/string_helper'
  require_relative 'helpers/url_helper'
  require_relative 'helpers/math_helper'
  require_relative 'helpers/discord_helper'
  require_relative 'helpers/japanese_helper'
  require_relative 'helpers/nekos_helper'

  # Database, Web and Permissions #
  require_relative 'data_access/database'
  require_relative 'data_access/tohsaka_bridge'
  require_relative 'data_access/trigger_data'
  require_relative 'data_access/msg_queue_cache'
  require_relative 'data_access/permissions'

  # Discord Bot #
  BOT = Discordrb::Commands::CommandBot.new(token: AUTH.bot_token,
                                            client_id: AUTH.cli_id,
                                            prefix: CFG.prefix.split(" "),
                                            advanced_functionality: false,
                                            fancy_log: true)

  # Sets permissions, 1000 being the highest
  TohsakaBot.set_permissions
  BOT.set_user_permission(AUTH.owner_id.to_i, 1000)

  # Discord Events and Commands #
  TohsakaBot.load_modules(:Commands, 'commands/*/*')
  TohsakaBot.load_modules(:Events, 'events/*/*')

  # Test Slash commands #
  # url = "https://discord.com/api/v8/applications/#{AUTH.cli_id}/commands"
  # payload = {
  #   "name": "huut",
  #   "description": "huutikset sulle",
  #   "options": [
  #     {
  #       "name": "huut",
  #       "description": "The type of huut",
  #       "type": 3,
  #       "required": true,
  #       "choices": [
  #         {
  #           "name": "Huutis",
  #           "value": "yes"
  #         },
  #         {
  #           "name": "Kuiskis",
  #           "value": "yes"
  #         },
  #         {
  #           "name": "Nauris",
  #           "value": "yes"
  #         }
  #       ]
  #     }
  #   ]
  # }
  #
  # # For authorization, you can use either your bot token
  # headers = {
  #   "Authorization": "Bot #{AUTH.bot_token}"
  # }
  #
  # puts HTTP.post(url, json: payload, headers: headers)

  # Asynchronous threads running in cycles #
  BOT.run(:async)

  # TODO: Load async threads dynamically
  # load_modules(:Async, 'async/*', false)
  require_relative 'async'

  # Cleans trigger files not present in the database.
  TohsakaBot.trigger_data.clean_trigger_files

  # Welcome messages
  puts "\n"
  %i[en ja fi].each { |locale| puts I18n.t :welcome, locale: locale }
  puts "\n"

  # Terminal tool to send messages through the bot.
  Thread.new do
    channel = CFG.default_channel.to_i
    puts I18n.t(:'bot.default_channel_notify') unless CFG.default_channel.match(/\d{18}/)

    while (user_input = gets.strip.split(' '))
      if user_input[0] == 'setch'
        channel = user_input[1].to_i
        puts "Channel set to #{BOT.channel(channel).name} "
      elsif user_input[0][0] == '.' && channel.match(/\d{18}/)
        BOT.send_message(channel, user_input.join(' ')[1..])
      end
    end
  end

  # Connection with TohsakaWeb #
  BRIDGE_URI = 'druby://localhost:8787'
  FRONT_OBJECT = TohsakaBridge.new
  DRb.start_service(BRIDGE_URI, FRONT_OBJECT)

  # Waits for the drb server thread to finish before exiting.
  DRb.thread.join
  BOT.sync
end
