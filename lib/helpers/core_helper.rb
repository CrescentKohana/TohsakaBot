module TohsakaBot
  module CoreHelper
    def load_modules(klass, path, discord = true, clear = false)
      modules = JSON.parse(File.read('cfg/bot_state.json')).transform_keys(&:to_sym)

      if clear
        BOT.clear!
        if klass == :Async
          modules[klass].each do |k|
            Thread.kill(k.to_s.downcase)
          end
        end
      end

      Dir["#{File.dirname(__FILE__)}/../#{path}.rb"].each { |file| load file }

      if discord
        modules[klass].each do |k|
          symbol_to_class = TohsakaBot.const_get("#{klass}::#{k}")
          TohsakaBot::BOT.include!(symbol_to_class)
        end
      end
    end

    def command_parser(event, msg, banner, extra_help = nil, *options)
      begin
        args = msg.join(' ')
        options_output = {}

        OptionParser.new do |parser|
          parser.banner = banner

          options.each do |o|
            parser.on(*o)
          end

          parser.on('-h', '--help', 'Prints help') do
            event.<< "```"
            event.<< parser
            event.<< extra_help
            event.<< "```"
            break
          end
        end.parse!(Shellwords.shellsplit(args), into: options_output)

      rescue OptionParser::InvalidOption => e
        event.respond "Tried to use an #{e}."
        return nil
      rescue OptionParser::MissingArgument => e
        event.respond "#{e}."
        return nil
      rescue OptionParser::NeedlessArgument => e
        event.respond "#{e}."
        return nil
      rescue OptionParser::ParseError => e
        event.respond "Error when parsing arguments: #{e}."
        return nil
      rescue OptionParser
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
  end

  TohsakaBot.extend CoreHelper
end
