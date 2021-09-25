# frozen_string_literal: true

require 'io/console'
require 'rainbow'
require 'active_support/core_ext/string'

class FirstTimeSetup
  def initialize(locale)
    @locale = locale
  end

  def valid_id?(id)
    Integer(id, exception: false)
  end

  def required_input(msg, integer, pwd: false)
    input = ""
    until !input.blank? && (!integer || valid_id?(input))
      print msg
      input = if pwd
                $stdin.noecho(&:gets).chomp
              else
                gets
              end

      input = input.encode("UTF-8", invalid: :replace, replace: "")
    end
    input
  end

  def create_data_files_and_configs
    Dir.mkdir('cfg') unless File.directory?('cfg')

    green = Rainbow("| ").green

    puts Rainbow("\n#{I18n.t(:'first_time_setup.required_hint')}\n").red
    puts Rainbow(I18n.t(:'first_time_setup.auth_file').to_s).green
    File.open('cfg/auth.yml', 'w') do |f|
      owner_id = required_input(green + I18n.t(:'first_time_setup.owner_id'), true)

      cli_id = required_input(green + I18n.t(:'first_time_setup.cli_id'), true)

      bot_token = required_input(green + I18n.t(:'first_time_setup.bot_token'), false, pwd: true)
      print("\n\n")

      database_type = required_input(green + I18n.t(:'first_time_setup.db_type'), true)
      print("\n\n")

      case database_type
      when 2
        database_type = 'mysql'
        db_user = required_input(green + I18n.t(:'first_time_setup.db_user'), false)
        db_password = required_input(green + I18n.t(:'first_time_setup.db_password'), false, pwd: true)
        sqlite_db = ''
      else
        database_type = 'sqlite'
        print green + I18n.t(:'first_time_setup.sqlite')
        sqlite_db = gets
        sqlite_db = sqlite_db.blank? ? 'tohsaka.db' : sqlite_db
        db_user = ''
        db_password = ''
      end
      print("\n\n")

      print green + I18n.t(:'first_time_setup.yt_apikey')
      yt_apikey = $stdin.noecho(&:gets).chomp
      print("\n")

      print green + I18n.t(:'first_time_setup.saucenao_apikey')
      saucenao_apikey = $stdin.noecho(&:gets).chomp
      print("\n")

      f.write(
        "#{I18n.t(:'first_time_setup.auth_cfg_notice1')}\n"\
        "owner_id: #{owner_id}"\
        "bot_token: #{bot_token}\n"\
        "cli_id: #{cli_id}"\
        "yt_apikey: #{yt_apikey}\n"\
        "saucenao_apikey: #{saucenao_apikey}\n\n"\
        "#{I18n.t(:'first_time_setup.auth_cfg_notice2')}\n"\
        "db_type: #{database_type}\n"\
        "db_user: #{db_user}\n"\
        "db_password: #{db_password}\n"\
        "db_name: tohsaka\n"\
        "db_url: localhost\n"\
        "sqlite_db: #{sqlite_db}\n"\
        "#{I18n.t(:'first_time_setup.auth_cfg_notice3')}\n"
      )
    end

    puts Rainbow("\n#{I18n.t(:'first_time_setup.config_file')}").green
    File.open('cfg/config.yml', 'w') do |f|
      print green + I18n.t(:'first_time_setup.prefix')
      prefix = gets
      print("\n")
      prefix = prefix.blank? ? "?" : prefix

      print green + I18n.t(:'first_time_setup.locale', lang: @locale.to_sym)
      locale = gets
      print("\n")
      locale = %w[en ja fi].include?(locale) ? locale : @locale

      default_channel = required_input(green + I18n.t(:'first_time_setup.default_channel'), true)

      print green + I18n.t(:'first_time_setup.highlight_channel')
      highlight_channel = gets
      print("\n")

      print green + I18n.t(:'first_time_setup.mvp_role')
      mvp_role = gets

      print green + I18n.t(:'first_time_setup.fool_role')
      fool_role = gets
      print("\n")

      print green + I18n.t(:'first_time_setup.web_dir')
      web_dir = gets
      print("\n")

      print green + I18n.t(:'first_time_setup.web_url')
      web_url = gets
      print("\n")

      f.write(
        "---\n"\
        "prefix: \"#{prefix.gsub("\n", '')}\"\n"\
        "locale: \"#{locale}\"\n"\
        "np: \"#{I18n.t(:'first_time_setup.default_now_playing')}\"\n"\
        "status:\n"\
        "- playing"\
        "- Tsukihime"\
        "default_channel: #{default_channel}"\
        "highlight_channel: #{highlight_channel}"\
        "web_dir: \"#{web_dir.gsub("\n", '')}\"\n"\
        "web_url: \"#{web_url.gsub("\n", '')}\"\n"\
        "nhk_api: \"https://rin.luukuton.fi/nhk/\"\n"\
        "reminder_limit: 100\n"\
        "trigger_limit: 10\n"\
        "temp_folder: \"tmp\"\n"\
        "default_trigger_chance: 5\n"\
        "del_trigger:\n"\
        "- not now rin\n"\
        "- no\n"\
        "- del\n"\
        "mvp_role: #{mvp_role}"\
        "fool_role: #{fool_role}"\
        "daily_neko: false\n"
      )
    end

    unless File.exist?('data/ask_rin_answers.csv')
      File.open('data/ask_rin_answers.csv', 'w') do |f|
        f.write(
          "Yes.\t0\n"\
          "No.\t0\n"\
          "I don't know.\t0\n"
        )
      end
    end

    File.open('data/temporary_roles.yml', 'w') { |f| f.write('--- {}') } unless File.exist?('data/temporary_roles.yml')
    File.open('data/squads_mute.yml', 'w') { |f| f.write('--- {}') } unless File.exist?('data/squads_mute.yml')
    File.open('data/timed_roles.yml', 'w') { |f| f.write('--- {}') } unless File.exist?('data/timed_roles.yml')

    unless File.exist?('data/roles.json')
      roles_hash = {
        "servers": [
          {
            "id": 1,
            "name": "Discord Example Server",
            "roles": [
              {
                "id": 1,
                "name": "Game",
                "group_size": 5,
                "permissions": 0
              },
              {
                "id": 2,
                "name": "Game 2",
                "group_size": 3,
                "permissions": 100
              }
            ]
          }
        ]
      }.freeze
      File.open('data/roles.json', 'w') { |f| f.write(JSON.pretty_generate(roles_hash)) }
    end

    Dir.mkdir('data/triggers') unless File.directory?('data/triggers')

    puts Rainbow("#{I18n.t(:'first_time_setup.files_created')}\n").red
  end
end
