# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class SlowMode
      def initialize(event, rate, channel_id)
        @event = event
        @channel_id = channel_id
        @rate = rate.to_i.clamp(0, 21_600) # 0s - 21600s (6h)
      end

      def run
        channels = []
        affected_channels = []

        if @channel_id == "all"
          channels = @event.server.channels
        elsif Integer(@channel_id, exception: false)
          channels << BOT.channel(@channel_id.to_i, @event.server.id)
        else
          channels << @event.channel
        end

        channels.each do |channel|
          next unless channel.text?

          channel.slowmode_rate = @rate
          affected_channels << channel
        end

        if affected_channels.empty?
          { content: I18n.t(:'commands.tool.admin.slow_mode.error.channel_not_found') }
        elsif @rate.positive?
          { content: I18n.t(:'commands.tool.admin.slow_mode.response.set', rate: @rate, channels: affected_channels.size) }
        else
          { content: I18n.t(:'commands.tool.admin.slow_mode.response.clear', channels: affected_channels.size) }
        end
      end
    end
  end
end
