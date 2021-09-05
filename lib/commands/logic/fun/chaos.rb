# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Chaos
      def initialize(event, text)
        @event = event
        @text = text.is_a?(Array) ? text.join(' ') : text
      end

      def run
        # The start of the message consists of 6 characters + the length of the ID: "<@!00000000000000000>: "
        trimmed = TohsakaBot.trim_message(@text, fixed_length: @event.author.id.to_s.length + 6)
        response = trimmed.strip_mass_mentions.gsub(/(?!^)..?/, &:capitalize)
        response[0] = response[0].downcase

        if @event.instance_of?(Discordrb::Events::ApplicationCommandEvent)
          { content: response.to_s }
        else
          { content: "<@#{@event.user.id}>: #{response}" }
        end
      end
    end
  end
end
