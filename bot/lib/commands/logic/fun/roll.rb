# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Roll
      def initialize(event, roll_size: 0, id_roll: false)
        @event = event
        @roll_size = roll_size
        @id_roll = id_roll
      end

      def run
        name = BOT.member(@event.server, @event.author.id).display_name

        if @id_roll
          button_id = 'id'
          content = "#{Roll.parse_msg_id(@event.message.id)} `#{name.sanitize_string}`"
        else
          button_id = @roll_size
          number = rand(0..("9" * @roll_size).to_i)
          content = "**#{number.to_s.rjust(@roll_size, '0')}**  `#{name.sanitize_string}`"
        end

        button = Discordrb::Components::View.new do |v|
          v.row do |r|
            r.button(style: :primary, label: '🎲', custom_id: "roll:#{button_id}")
          end
        end

        {
          content: content,
          components: button
        }
      end

      def self.parse_msg_id(id)
        a, _b, c = /((\d)(?:\2*))(\d+)/.match(id.to_s.reverse).captures
        "#{c.reverse}**#{a}**"
      end
    end
  end
end
