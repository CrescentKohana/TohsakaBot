# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Pitch
      def initialize(event, word)
        @event = event
        @word = word
      end

      def run
        results = TohsakaBot.get_accents(@word)
        return { content: I18n.t(:'commands.japanese.pitch.errors.no_results'), embeds: nil } if results.blank?

        response = TohsakaBot.construct_response(results)
        builder = Discordrb::Webhooks::Builder.new
        builder.add_embed do |e|
          e.colour = 0x36393F
          e.title = I18n.t(:'commands.japanese.pitch.response_title', word: response[0])
          e.description = response[1]
        end

        { content: nil, embeds: builder.embeds.map(&:to_hash) }
      end
    end
  end
end

