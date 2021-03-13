# frozen_string_literal: true

module TohsakaBot
  module Events
    module HighlightReaction
      extend Discordrb::EventContainer
      reaction_add(emoji: '📌') do |event|
        next if event.channel.pm?

        highlight_core = HighlightCore.new(event.message, event.server.id, event.channel.id)
        next unless highlight_core.requirements_for_pin_met?

        highlight_core.store_highlight(highlight_core.send_highlight)
      end
    end
  end
end
