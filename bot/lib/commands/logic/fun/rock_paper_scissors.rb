# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class RockPaperScissors
      def initialize(event)
        @event = event
        @challenger = event.message.author.id.to_i
        @challenged = event.message.mentions.empty? ? nil : event.message.mentions.first.id.to_i
      end

      def run
        buttons = Discordrb::Components::View.new do |v|
          v.row do |r|
            r.button(style: :primary, label: '🪨', custom_id: 'rps:0')
            r.button(style: :primary, label: '📃', custom_id: 'rps:1')
            r.button(style: :primary, label: '✂', custom_id: 'rps:2')
          end
        end

        TohsakaBot.rps_cache.new_game(@event.message.id, @challenger, @challenged)

        {
          content: "<@!#{@challenger}> VS #{@challenged.nil? ? '?' : "<@!#{@challenged}>"}",
          components: buttons
        }
      end
    end
  end
end
