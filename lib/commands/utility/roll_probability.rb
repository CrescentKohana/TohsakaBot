module TohsakaBot
  module Commands
    module RollProbability
      extend Discordrb::Commands::CommandContainer
      command(:rollprobability,
              aliases: %i[rollchance chanceroll rollp rollc],
              description: 'Calculates the probability of getting Z correct in X amount of rolls with the chance of Y',
              usage: 'rollprobability <chance in % (float|int)> <times (int)> <correct times (int)',
              min_args: 2) do |event, chance, times, correct|

        chance = chance.to_f / 100
        times = times.to_i
        correct = correct.to_i

        if chance > 1.0 || times > 1000 || correct > 1000
          event.<< "Limits for the arguments are 100 (chance), 1000 (times), 1000 (correct)."
          break
        end

        if times < correct
          event.<< "Total times has to be equal or more than correct times."
          break
        end

        # Source for the binomial coefficent "n choose k" below
        # https://creativecommons.org/licenses/by-sa/3.0/ "Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)"
        # https://www.programming-idioms.org/idiom/67/binomial-coefficient-n-choose-k/1656/ruby (2020/06/03)
        def self.ncr(n, k)
          (1 + n - k..n).inject(:*) / (1..k).inject(:*)
        end

        x = 0
        i = 0
        (times - correct).times do
          x += ncr(times, correct + i)
          i += 1
        end

        probability = ((chance**times) * ((x + ncr(times, times)))) * 100
        #probability = (1 - ((1 - (chance)) ** times)) * 100 for "one or more"

        event.<< "The probability of #{correct} or more being correct in #{times} rolls with the chance of #{chance * 100}% is approximately #{probability}%."
      end
    end
  end
end
