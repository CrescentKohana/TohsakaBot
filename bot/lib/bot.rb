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
require 'digest'
require "base64"
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

# Overrides for discordrb gem
require_relative 'gem_overrides/discordrb_command_override'
require_relative 'gem_overrides/cache_override'
require_relative 'gem_overrides/interaction_override'

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
  require_relative 'helpers/time_helper'
  require_relative 'helpers/url_helper'
  require_relative 'helpers/math_helper'
  require_relative 'helpers/discord_helper'
  require_relative 'helpers/japanese_helper'
  require_relative 'helpers/nekos_helper'

  # Database, Web, Permissions and Polls #
  require_relative 'data_access/database'
  require_relative 'data_access/tohsaka_bridge'
  require_relative 'data_access/trigger_data'
  require_relative 'data_access/permissions'
  require_relative 'data_access/msg_queue_cache'
  require_relative 'data_access/poll_cache'
  require_relative 'data_access/rps_cache'

  # Custom command matcher. Currently only for case insensitive commands.
  prefix_proc = proc do |message|
    match = /^[#{CFG.prefix}](\w+)(.*)/.match(message.content)
    if match
      command_name = match[1]
      rest = match[2]
      "#{command_name.downcase}#{rest}"
    end
  end

  # Discord Bot #
  BOT = Discordrb::Commands::CommandBot.new(token: AUTH.bot_token,
                                            client_id: AUTH.cli_id,
                                            prefix: prefix_proc,
                                            advanced_functionality: false,
                                            fancy_log: true,
                                            log_mode: :normal)

  # Command logic classes #
  Dir[File.join(__dir__, 'commands/logic/*/', '*.rb')].sort.each { |file| require file }
  Dir[File.join(__dir__, 'commands/logic/*/*/', '*.rb')].sort.each { |file| require file }
  # Discord Events and Commands #
  TohsakaBot.load_modules(:Commands, %w[commands/txt/* commands/txt/*/* commands/txt/*/*/*])
  TohsakaBot.load_modules(:Slash, %w[commands/slash/*], discord: false)
  TohsakaBot.load_modules(:Events, %w[events/*/*])

  # Asynchronous threads running in cycles #
  BOT.run(true)

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
    puts I18n.t(:'bot.default_channel_notify') unless CFG.default_channel.to_s.match(/\d{18}/)

    while (user_input = gets&.strip&.split(' '))
      next if user_input.blank?

      if user_input[0] == 'set_ch'
        channel = user_input[1].to_i
        puts I18n.t(:'bot.channel_set', name: BOT.channel(channel)&.name)
      elsif user_input[0][0] == '.' && channel.to_s.match(/\d{18}/)
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
  BOT.join
end
