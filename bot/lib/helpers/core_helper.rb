# frozen_string_literal: true

require 'optimist'
require 'shellwords'
require 'redcarpet'
require 'redcarpet/render_strip'

module TohsakaBot
  module CoreHelper
    def load_modules(klass, paths, discord: true, clear: false)
      modules = filter_modules

      BOT.clear! if clear

      paths.each do |path|
        Dir["#{File.dirname(__FILE__)}/../#{path}.rb"].each { |file| load file }
      end

      return unless discord

      modules[klass].each do |k|
        symbol_to_class = TohsakaBot.const_get("#{klass}::#{k}")
        BOT.include!(symbol_to_class)
      end
    end

    def filter_modules
      modules = JSON.parse(File.read(CFG.data_dir + '/persistent/bot_state.json')).transform_keys(&:to_sym)
      modules[:Commands].delete("GetSauce") if AUTH.saucenao_apikey.blank?
      modules[:Commands].delete("GetPitch") if CFG.nhk_api.blank?

      # TODO
      # modules[:Commands].delete("MVP") if CFG.mvp_role.blank?
      # modules[:Commands].delete("Fool") if CFG.fool_role.blank?
      # if CFG.highlight_channel.blank?
      #   modules[:Events].delete("HighlightReaction")
      #   modules[:Events].delete("HighlightDelete")
      # end

      modules
    end

    def command_parser(event, msg, banner, extra_help, *option_input)
      old_help = false
      args = Shellwords.split(msg.join(' '))

      begin
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

        parser.parse(args)
      rescue Optimist::HelpNeeded
        help_string = construct_help(option_input)

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
        nil
      rescue Optimist::CommandlineError => e
        TohsakaBot.expire_msg(event.channel, [event.respond(e)], event.message)
        nil
      end
    end

    # Strips markdown from a string.
    #
    # @param input [String, Array] Text with markdown
    # @return [String, Array] Text without markdown
    def strip_markdown(input)
      return Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(input).to_s if input.is_a?(String)

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

    private

    def construct_help(options)
      help_string = ''.dup
      options.each do |o|
        name = o[0].to_s
        help_string << "`-#{name[0]}"
        help_string << ", --#{name} #{name.capitalize}`"
        help_string << "\n・#{o[1]}\n"
      end

      help_string
    end
  end

  TohsakaBot.extend CoreHelper
end
