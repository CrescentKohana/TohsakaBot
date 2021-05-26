# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Number
      def initialize(event, one, two)
        @event = event
        @one = one
        @two = two
      end

      def run
        if (@one.nil? && @two.nil?) || (!Integer(@one, exception: false) || !Integer(@two, exception: false))
          @one = 0
          @two = 9
        end

        if @one.to_i < -100_000_000 || @two.to_i > 100_000_000
          return { response: "Don't break the bot (range: -100000000 - 100000000).", reference: nil }
        end

        @two, @one = @one, @two if @one.to_i > @two.to_i
        number = rand(@one.to_i..@two.to_i)

        msg_ref = nil # Discordrb::Events::ApplicationCommandEvent
        msg_ref = @event.message if @event.instance_of?(Discordrb::Commands::CommandEvent)
        { content: "**#{number}** 🎲 (#{@one}..#{@two})", reference: msg_ref }
      end
    end
  end
end
