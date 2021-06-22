# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Roll
      def initialize(event, roll_size)
        @event = event
        @roll_size = roll_size
      end

      def run
        number = rand(0..("9" * @roll_size).to_i)
        name = BOT.member(@event.server, @event.author.id).display_name

        button = Discordrb::Components::View.new do |v|
          v.row do |r|
            r.button(style: :primary, label: '🎲', custom_id: "roll:#{@roll_size}")
          end
        end

        { content: "**#{number.to_s.rjust(2, '0')}**  `#{name.sanitize_string}`", components: button }
      end
    end
  end
end
