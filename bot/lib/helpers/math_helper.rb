# frozen_string_literal: true

module TohsakaBot
  module MathHelper
    # Source for the binomial coefficient "n choose k" below
    # https://creativecommons.org/licenses/by-sa/3.0/ "Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)"
    # https://www.programming-idioms.org/idiom/67/binomial-coefficient-n-choose-k/1656/ruby (2020/06/03)
    def ncr(n, k)
      (1 + n - k..n).inject(:*) / (1..k).inject(:*)
    end

    # n = total rolls, k = total hits, p = chance to hit
    # (n choose k) * (p^k) * ((1-p)^(n-k))
    def calc_probability(n, k, p)
      # Strange bug where ncr(n, k) * (p ** k) would sometimes give NaN instead of 0.0
      # is fixed by checking if a step is NaN and converting it into 0.0.
      # ncr(n, k) * (p ** k) * ((1 - p) ** (n - k))
      step = (ncr(n, k) * (p**k))
      step = 0.0 if step.nan?
      step * (1 - p)**(n - k)
    end
  end

  TohsakaBot.extend MathHelper
end
