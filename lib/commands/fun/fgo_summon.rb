module TohsakaBot
  module Commands
    module FGOSummon
      extend Discordrb::Commands::CommandContainer
      command(:fgosummon,
              aliases: %i[fgo summonfgo shoukan 召喚],
              description: 'Returns probabilities of different summons in Fate/Grand Order.',
              usage: 'fgosummon <currency (SQ, JPY or USD as int; default SQ, otherwise add JPY/USD at the end> <verbose (y/N)>',
              min_args: 1) do |event, currency, verbose|

        currency = currency.scan(/\d+|[A-Za-z]+/)
        if currency.length == 1
          rolls = (currency[0].to_i / 3)
          rolls += rolls / 10
          currency << 'SQ'
        else
          if currency[1] == 'SQ'
            rolls = (currency[0].to_i / 3).to_i
          elsif currency[1] == 'USD'
            rolls = (currency[0].to_i * ((168.0 / 79.99) / 3)).to_i
          elsif currency[1] == 'JPY'
            rolls = (currency[0].to_i * ((168.0 / 10000) / 3)).to_i
          else
            event.<< "Accepted currency suffixes: SQ, JPY, USD or no suffix."
            break
          end
        end

        # Chances (source: FGO JP)
        # se: Servant, ce: Craft Essence, ru: Rateup
        c = {
            :se_ssr_ru => 0.008, :se_sr_ru => 0.015, :se_r_ru => 0.04,
            :ce_ssr_ru => 0.028, :ce_sr_ru => 0.04, :ce_r_ru => 0.8,
            :se_ssr => 0.01, :se_sr => 0.03, :se_r => 0.4,
            :ce_ssr => 0.04, :ce_sr => 0.12, :ce_r => 0.40
        }

        # Source for the binomial coefficent "n choose k" below
        # https://creativecommons.org/licenses/by-sa/3.0/ "Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)"
        # https://www.programming-idioms.org/idiom/67/binomial-coefficient-n-choose-k/1656/ruby (2020/06/03)
        def self.ncr(n, k)
          (1 + n - k..n).inject(:*) / (1..k).inject(:*)
        end

        # n = total rolls, k = total hits, p = chance to hit
        # (n choose k) * (p^k) * ((1-p)^(n-k))
        def self.calc_probability(n, k, p)
          ncr(n, k) * (p ** k) * ((1 - p) ** (n - k))
        end

        def self.summon_prob(rolls, chance)
          # Skipping all slow calculations which would return more than 0.9999 probability.
          return "≈99.99" if (rolls * chance) > 9.09 || rolls >= 1097 # 8.239

          probability = 0
          (1..rolls).each { |i| probability += calc_probability(rolls, i, chance) }
          '%.2f' % (probability * 100).round(2)
        end

        # Calculate everything to a hash 'c'
        c.each { |k, v| c[k] = summon_prob(rolls, v) }

        event.send_embed do |e|
          e.title = "**Fate/Grand Order 聖晶石召喚**"
          e.colour = 0x032046
          e.footer = Discordrb::Webhooks::EmbedFooter.new(text: "#{currency[0]}#{currency[1]} | #{rolls} rolls", icon_url: "https://vignette.wikia.nocookie.net/fategrandorder/images/f/ff/Saintquartz.png/revision/latest/")
          # e.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Rin", icon_url: "")

          e.add_field(name: "Chances",
                      value:
                          "**#{c[:se_ssr_ru]}%** Servant (RUp SSR)\n"\
                          "**#{c[:se_ssr]}%** Servant (SSR)\n"\
                          "**#{c[:se_sr_ru]}%** Servant (RUp SR)\n"\
                          "**#{c[:se_sr]}%** Servant (SR)\n"\
                          "**#{c[:ce_ssr_ru]}%** CE (RUp SSR)\n"\
                          "**#{c[:ce_sr_ru]}%** CE (RUp SR)\n") unless verbose

          e.add_field(name: "Chances (verbose)",
                      value:
                          "**#{c[:se_ssr_ru]}%** Servant (RUp SSR)\n"\
                          "**#{c[:se_ssr]}%** Servant (SSR)\n"\
                          "**#{c[:se_sr_ru]}%** Servant (RUp SR)\n"\
                          "**#{c[:se_sr]}%** Servant (SR)\n"\
                          "**#{c[:se_r_ru]}%** Servant (RUp R)\n"\
                          "**#{c[:se_r]}%** Servant (R)\n"\
                          "**#{c[:ce_ssr_ru]}%** CE (RUp SSR)\n"\
                          "**#{c[:ce_ssr]}%** CE (SSR)\n"\
                          "**#{c[:ce_sr_ru]}%** CE (RUp SR)\n"\
                          "**#{c[:ce_sr]}%** CE (SR)\n"\
                          "**#{c[:ce_r_ru]}%** CE (RUp R)\n"\
                          "**#{c[:ce_r]}%** CE (R)\n") if verbose
        end
      end
    end
  end
end
