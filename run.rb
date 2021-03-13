# frozen_string_literal: true

if !File.exist?('cfg/auth.yml') || !File.exist?('cfg/config.yml') || ARGV.include?("reset")
  require 'i18n'
  require "i18n/backend/fallbacks"

  I18n::Backend::Simple.include I18n::Backend::Fallbacks
  I18n.load_path << Dir["#{File.expand_path('locales')}/*.yml"]
  I18n.fallbacks.map(fi: :en, ja: :en)

  require_relative 'lib/first_time_setup'
  locale = ARGV[0].nil? || ARGV[0] == "first" ? "en" : ARGV[0]
  unless %w[en ja fi].include?(locale)
    puts "#{locale} is not a valid locale."
    exit
  end

  setup = FirstTimeSetup.new(locale)
  setup.create_data_files_and_configs
  exit
end

require_relative 'lib/bot'
