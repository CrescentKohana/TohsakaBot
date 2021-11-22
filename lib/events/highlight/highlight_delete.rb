# frozen_string_literal: true

module TohsakaBot
  module Events
    module HighlightDelete
      extend Discordrb::EventContainer
      highlight_channels = TohsakaBot.server_cache.map(&:highlight_channel)
      unless highlight_channels.empty?
        message_delete(in: highlight_channels) do |event|
          HighlightCore.delete_highlight(event.id.to_i)
        end
      end
    end
  end
end
