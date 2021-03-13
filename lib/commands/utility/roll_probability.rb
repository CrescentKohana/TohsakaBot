# frozen_string_literal: true

module TohsakaBot
  module Commands
    module RollProbability
      extend Discordrb::Commands::CommandContainer
      command(:rollprobability,
              aliases: %i[rollchance chanceroll rollp rollc],
              description: 'Returns the probability of getting k hits within n amount of rolls with the chance of p.',
              usage: 'rollprobability <chance in % (float|int)> <rolls (int)> <hits (int, default: 1)>',
              min_args: 2) do |event, chance, rolls, hits|
        chance = chance.to_f / 100
        rolls = rolls.to_i
        hits = hits.to_i || 1

        unless (0..100).include?(chance) || (1..1000).include?(rolls) || (1..1000).include?(hits)
          event.<< 'Limits for the arguments are 0-100 (chance), 1-1000 (times), 1-1000 (correct).'
          break
        end

        if rolls < hits
          event.<< 'Total times has to be equal or more than correct times.'
          break
        end

        probability_one = TohsakaBot.calc_probability(rolls, hits, chance)
        probability_one_or_more = probability_one

        (hits + 1..rolls).each do |i|
          probability_one_or_more += TohsakaBot.calc_probability(rolls, i, chance)
        end

        reply = "The probability of #{hits} or more being correct within #{rolls} rolls"\
                " with the chance of #{chance * 100}% is approximately #{probability_one_or_more * 100}%."
        event.respond reply
      end
    end
  end
end
