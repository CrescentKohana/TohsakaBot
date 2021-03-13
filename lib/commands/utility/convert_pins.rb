# frozen_string_literal: true

module TohsakaBot
  module Commands
    module ConvertPins
      require_relative '../../events/highlight/highlight_core'
      extend Discordrb::Commands::CommandContainer
      command(:convertpins,
              description: 'Copies all pinned messages on the specified channel to database and posts them to the highlight channel',
              usage: 'convertpins <Newest|oldest (starting point)> <channel_id (if empty, current channel will be used)> ',
              permission_level: 1000) do |event, order, channel_id|
        channel = if channel_id.nil?
                    event.channel
                  else
                    BOT.channel(channel_id.to_i)
                  end

        pinned_messages = channel.pins
        pinned_messages.reverse! if !order.nil? && order == 'oldest'

        msg = event.respond('Converting...')

        pinned_messages.each do |m|
          next unless TohsakaBot.db[:highlights].where(msg_id: m.id.to_i).empty?

          highlight_core = HighlightCore.new(m, channel.server.id.to_i, channel.id.to_i)
          highlight_core.store_highlight(highlight_core.send_highlight)
          sleep(2)
        end

        msg.edit('Done!')
        break
      end
    end
  end
end
