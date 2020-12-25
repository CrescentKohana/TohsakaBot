module TohsakaBot
  module Events
    module HighlightReaction
      extend Discordrb::EventContainer
      reaction_add(emoji: '📌') do |event|
        highlight_core = HighlightCore.new(event.message, event.server.id, event.channel.id)
        next unless highlight_core.requirements_for_pin_met?
        highlight_core.send_highlight
      end
    end
  end
end
