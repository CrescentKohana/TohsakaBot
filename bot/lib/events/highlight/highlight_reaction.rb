# frozen_string_literal: true

module TohsakaBot
  module Events
    module HighlightReaction
      def self.highlight_helper(event)
        return if event.channel.pm?

        highlight_core = HighlightCore.new(event.message, event.server.id, event.channel.id)
        return unless highlight_core.requirements_for_pin_met?

        highlight_core.store_highlight(highlight_core.send_highlight(event.server.id))
      end

      extend Discordrb::EventContainer
      reaction_add(emoji: '📌') do |event|
        highlight_helper(event)
        next
      end
      reaction_add(emoji: '📍') do |event|
        highlight_helper(event)
        next
      end
    end
  end
end
