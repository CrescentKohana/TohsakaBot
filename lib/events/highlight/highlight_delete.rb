# frozen_string_literal: true

module TohsakaBot
  module Events
    module HighlightDelete
      extend Discordrb::EventContainer
      unless CFG.highlight_channel.blank?
        message_delete(in: BOT.channel(CFG.highlight_channel)) do |event|
          HighlightCore.delete_highlight(event.id.to_i)
        end
      end
    end
  end
end
