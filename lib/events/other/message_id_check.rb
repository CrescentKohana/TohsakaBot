# frozen_string_literal: true

module TohsakaBot
  module Events
    module MessageIDCheck
      extend Discordrb::EventContainer
      message do |event|
        next if event.channel.pm? || event.user.bot_account

        first, second = /(\d)(\1*$)/.match(event.message.id.to_s).captures
        capture = first.to_s + second.to_s
        @length = capture.length
        @msg = event.message.content
        next unless @length > 1

        def self.check_pair(min_length, naming)
          @length >= min_length && @msg.match(/^#{naming}.*/i)
        end

        name = BOT.member(event.server, event.message.author.id).display_name.strip_mass_mentions.sanitize_string

        if @length > 10
          reply = "#{I18n.t(:'events.message_id_check.what')} 🆔 **#{capture}**"
        else
          next unless @length >= 5 || check_pair(2, "dubs") || check_pair(3, "trips") || check_pair(4, "quads")

          if @length >= 6
            highlight_core = HighlightCore.new(event.message, event.server.id, event.channel.id)
            highlight_core.store_highlight(highlight_core.send_highlight(event.server.id))
          end
          i18n_code = "events.message_id_check.#{@length}".to_sym
          reply = "#{I18n.t(i18n_code, locale: TohsakaBot.get_locale(event.user.id))} 🆔 **…#{capture}**"
        end

        event.respond("#{reply} `#{name}`", false, nil, nil, false, event.message)
      end
    end
  end
end
