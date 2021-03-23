# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Neko
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 2
      command(:neko,
              aliases: %i[cat],
              description: 'A cat.',
              usage: 'neko <type>',
              bucket: :cf,
              rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, type|
        if TohsakaBot.neko_types.include?(type.to_s)
          url = TohsakaBot.get_neko(type)
          unless event.channel.nsfw
            event.respond "Images only work in NSFW marked channels."
            break
          end
          break unless URI::DEFAULT_PARSER.make_regexp.match?(url)

          event.<< url
        elsif TohsakaBot.neko_txt_types.include?(type.to_s)
          msg = TohsakaBot.get_neko(type)
          event.<< msg
        else
          event.respond "**img**```#{TohsakaBot.neko_types.join(' ')}```**txt**```#{TohsakaBot.neko_txt_types.join(' ')}```"
        end
      end
    end
  end
end
