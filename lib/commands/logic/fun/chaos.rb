# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Chaos
      def initialize(event, text)
        @event = event
        @text = text.is_a?(Array) ? text.join(' ') : text
      end

      def run
        ch_msg = @text.strip_mass_mentions.gsub(/(?!^)..?/, &:capitalize)
        ch_msg[0] = ch_msg[0].downcase

        if @event.instance_of?(Discordrb::Events::ApplicationCommandEvent)
          { content: ch_msg.to_s }
        else
          { content: "<@#{@event.user.id}>: #{ch_msg}" }
        end
      end
    end
  end
end
