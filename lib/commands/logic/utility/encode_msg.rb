# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class EncodeMsg
      def initialize(event, algorithm, msg)
        @event = event
        @algorithm = algorithm
        @msg = msg
      end

      def run
        # TODO: More encoding methods.
        encoded_msg =  case @algorithm
                       when "base64"
                         Base64.encode64(@msg).gsub("\n", "") + "\u2063" * 2
                       else # rot13
                         @msg.tr('a-zA-Z', 'n-za-mN-ZA-M') + "\u2063"
                       end

        { content: encoded_msg, channel_id: @event.channel_id }
      end
    end
  end
end
