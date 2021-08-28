# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Martus
      def initialize(event, text)
        @event = event
        @text = text.is_a?(Array) ? text.join(' ') : text
      end

      def run
        ch_msg = @text.strip_mass_mentions.gsub(/k/i, "t").upcase

        if @event.instance_of?(Discordrb::Events::ApplicationCommandEvent)
          { content: ch_msg.to_s }
        else
          { content: "<@#{@event.user.id}>: #{ch_msg}" }
        end
      end
    end
  end
end
