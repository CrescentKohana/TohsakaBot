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
        ch = {
            :se_ssr_ru => 0.008, :se_sr_ru => 0.015,
            :ce_ssr_ru => 0.028, :ce_sr_ru => 0.04,
            :se_ssr => 0.01, :se_sr => 0.03
        }

        ch_verbose = {
            :se_r_ru => 0.04, :ce_r_ru => 0.8, :se_r => 0.4,
            :ce_ssr => 0.04, :ce_sr => 0.12, :ce_r => 0.40
        }

        def self.summon_prob(rolls, chance)
          # Skipping all slow calculations which would return more than 0.9999 probability.
          return "≈99.99" if (rolls * chance) > 8.239 || rolls >= 1097 # 9.09

          probability = 0
          (1..rolls).each { |i| probability += TohsakaBot.calc_probability(rolls, i, chance) }
          '%.2f' % (probability * 100).round(2)
        end

        # Calculate everything to a hash 'c'
        ch.each { |k, v| ch[k] = summon_prob(rolls, v) }
        ch_verbose.each { |k, v| ch_verbose[k] = summon_prob(rolls, v) } if verbose

        event.send_embed do |e|
          e.title = "**Fate/Grand Order 聖晶石召喚**"
          e.colour = 0x032046
          e.footer = Discordrb::Webhooks::EmbedFooter.new(text: "#{currency[0]}#{currency[1]} | #{rolls} rolls", icon_url: "https://vignette.wikia.nocookie.net/fategrandorder/images/f/ff/Saintquartz.png/revision/latest/")
          # e.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Rin", icon_url: "")

          e.add_field(name: "Chances",
                      value:
                          "**#{ch[:se_ssr_ru]}%** Servant (RUp SSR)\n"\
                          "**#{ch[:se_ssr]}%** Servant (SSR)\n"\
                          "**#{ch[:se_sr_ru]}%** Servant (RUp SR)\n"\
                          "**#{ch[:se_sr]}%** Servant (SR)\n"\
                          "**#{ch[:ce_ssr_ru]}%** CE (RUp SSR)\n"\
                          "**#{ch[:ce_sr_ru]}%** CE (RUp SR)\n") unless verbose

          e.add_field(name: "Chances (verbose)",
                      value:
                          "**#{ch[:se_ssr_ru]}%** Servant (RUp SSR)\n"\
                          "**#{ch[:se_ssr]}%** Servant (SSR)\n"\
                          "**#{ch[:se_sr_ru]}%** Servant (RUp SR)\n"\
                          "**#{ch[:se_sr]}%** Servant (SR)\n"\
                          "**#{ch_verbose[:se_r_ru]}%** Servant (RUp R)\n"\
                          "**#{ch_verbose[:se_r]}%** Servant (R)\n"\
                          "**#{ch[:ce_ssr_ru]}%** CE (RUp SSR)\n"\
                          "**#{ch_verbose[:ce_ssr]}%** CE (SSR)\n"\
                          "**#{ch[:ce_sr_ru]}%** CE (RUp SR)\n"\
                          "**#{ch_verbose[:ce_sr]}%** CE (SR)\n"\
                          "**#{ch_verbose[:ce_r_ru]}%** CE (RUp R)\n"\
                          "**#{ch_verbose[:ce_r]}%** CE (R)\n") if verbose
        end
      end
    end
  end
end
