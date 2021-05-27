# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class RollProbability
      def initialize(event, chance, rolls, hits)
        @event = event
        @chance = chance.to_f / 100
        @rolls = rolls.to_i
        @hits = hits.to_i || 1
      end

      def run
        unless (0..100).include?(@chance) || (1..1000).include?(@rolls) || (1..1000).include?(@hits)
          return { content: "Limits for the arguments are 0-100 (chance), 1-1000 (times), 1-1000 (correct)." }
        end

        return { content: "Total times has to be equal or more than correct times." } if @rolls < @hits

        probability_one = TohsakaBot.calc_probability(@rolls, @hits, @chance)
        probability_one_or_more = probability_one

        (@hits + 1..@rolls).each do |i|
          probability_one_or_more += TohsakaBot.calc_probability(@rolls, i, @chance)
        end

        reply = "The probability of #{@hits} or more being correct within #{@rolls} rolls"\
                " with the chance of #{@chance * 100}% is approximately #{probability_one_or_more * 100}%."
        { content: reply }
      end
    end
  end
end
