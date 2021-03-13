# frozen_string_literal: true

module TohsakaBot
  module CoreHelper
    def load_modules(klass, path, discord: true, clear: false)
      modules = JSON.parse(File.read('data/persistent/bot_state.json')).transform_keys(&:to_sym)

      BOT.clear! if clear

      if clear && klass == :Async
        modules[klass].each do |k|
          Thread.kill(k.to_s.downcase)
        end
      end

      Dir["#{File.dirname(__FILE__)}/../#{path}.rb"].each { |file| load file }

      return unless discord

      modules[klass].each do |k|
        symbol_to_class = TohsakaBot.const_get("#{klass}::#{k}")
        BOT.include!(symbol_to_class)
      end
    end

    def command_parser(event, msg, banner, extra_help, *option_input)
      begin
        old_help = false
        args = Shellwords.split(msg.join(' '))

        parser = Optimist::Parser.new do
          option_input.each do |o|
            opt(*o)
          end

          opt :old do
            old_help = true
            raise Optimist::HelpNeeded
          end

          opt :help do
            raise Optimist::HelpNeeded
          end
        end

        options_output = parser.parse args
      rescue Optimist::HelpNeeded
        help_string = ''.dup
        option_input.each do |o|
          option = o[0].to_s
          help_string << "`-#{option[0]}"
          help_string << ", --#{option} #{option.capitalize}`"
          help_string << "\n・#{o[1]}\n"
        end

        if old_help
          respond = "```#{banner}\n#{help_string}\n#{extra_help}```"
          m = event.respond respond
        else
          m = event.send_embed do |embed|
            embed.colour = 0xA82727
            embed.add_field(name: banner.to_s, value: help_string.to_s)
            embed.add_field(name: "Extra", value: extra_help.to_s) unless extra_help.blank?
          end
        end

        TohsakaBot.expire_msg(event.channel, [m], event.message)
        return nil
      end

      options_output
    end

    def strip_markdown(input)
      return Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(input).to_s if input.is_a? String

      return_array = []
      input.each { |s| return_array << Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(s).to_s }
      return_array
    end

    # Returns all aliases in every language for a command.
    #
    # @param i18n_path [String] i18n native path to a translation (eg. "commands.utility.ping.aliases")
    # @return [Array] Symbol array of command aliases
    def get_command_aliases(i18n_path)
      aliases = %i[]
      %i[en ja fi].each do |locale|
        aliases += I18n.t(i18n_path.to_sym, locale: locale.to_sym).split(" ").map(&:to_sym)
      end
      aliases
    end
  end

  TohsakaBot.extend CoreHelper
end
