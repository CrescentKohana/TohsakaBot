# frozen_string_literal: true

module TohsakaBot
  module Commands
    module FGOSummon
      extend Discordrb::Commands::CommandContainer
      command(:fgosummon,
              aliases: %i[fgo summonfgo shoukan 召喚],
              description: 'Returns probabilities of different summons in Fate/Grand Order.',
              usage: 'fgosummon <currency (SQ, JPY, USD or R (rolls) as int; default SQ, otherwise add JPY/USD/R at the end> <verbose (y/N)>',
              min_args: 1) do |event, currency, verbose|
        currency = currency.scan(/\d+|[A-Za-z]+/)
        if currency.length == 1
          rolls = (currency[0].to_i / 3)
          rolls += rolls / 10
          currency << 'SQ'
        else
          case currency[1]
          when 'SQ'
            rolls = (currency[0].to_i / 3).to_i
          when 'USD'
            rolls = (currency[0].to_i * ((168.0 / 79.99) / 3)).to_i
          when 'JPY'
            rolls = (currency[0].to_i * ((168.0 / 10_000) / 3)).to_i
          when 'R'
            rolls = currency[0].to_i
          else
            event.<< 'Accepted currency suffixes: SQ, JPY, USD or no suffix.'
            break
          end
        end

        # Chances (source: FGO JP)
        # se: servant, ce: Craft Essence, ru: Rateup
        ch = {
          se_ssr_ru: 0.008, se_sr_ru: 0.015,
          ce_ssr_ru: 0.028, ce_sr_ru: 0.04,
          se_ssr: 0.01, se_sr: 0.03
        }

        ch_verbose = {
          se_r_ru: 0.04, ce_r_ru: 0.08, se_r: 0.4,
          ce_ssr: 0.04, ce_sr: 0.12, ce_r: 0.40
        }

        def self.summon_prob(rolls, chance)
          # Skipping all slow calculations which would basically return >= 0.9999 probability.
          #
          # 1-((1-0.008)^1097) ≈ 0.999851 (SSR on rateup)
          # 1097 * 0.008 = 8.776
          #
          # 1-((1-0.01)^877) ≈ 0.999851 (SSR)
          # 877 * 0.01 = 8.77
          return '≈ 99.99' if (rolls * chance) > 8.77 || rolls >= 1097

          probability = 0
          (1..rolls).each { |i| probability += TohsakaBot.calc_probability(rolls, i, chance).to_f }
          "≈ #{'%.2f' % (probability * 100).round(2)}"
        end

        # Calculate everything to a hash 'c'
        time = Benchmark.measure do
          ch.each { |k, v| ch[k] = summon_prob(rolls, v.to_f) }
          ch_verbose.each { |k, v| ch_verbose[k] = summon_prob(rolls, v.to_f) } if verbose
        end

        event.send_embed do |e|
          e.title = 'Fate/Grand Order 召喚'
          e.colour = 0x032046
          e.description = 'Verbose' if verbose
          e.footer = Discordrb::Webhooks::EmbedFooter.new(
            text: "#{currency[0]}#{currency[1]} | #{rolls} roll#{'s' if rolls > 1} | #{time.real.round(4)}s",
            icon_url: 'https://vignette.wikia.nocookie.net/fategrandorder/images/f/ff/Saintquartz.png/revision/latest/'
          )

          unless verbose
            e.add_field(name: 'Chances (^rateup)',
                        value:
                            "```SSR^ #{ch[:se_ssr_ru]}%\n"\
                            "SSR  #{ch[:se_ssr]}%\n"\
                            "SR^  #{ch[:se_sr_ru]}%\n"\
                            "SR   #{ch[:se_sr]}%\n"\
                            "SSR^ #{ch[:ce_ssr_ru]}% (CE)```")
          end

          if verbose
            e.add_field(name: 'Servant Chances (^rateup)',
                        value:
                            "```SSR^ #{ch[:se_ssr_ru]}%\n"\
                            "SSR  #{ch[:se_ssr]}%\n"\
                            "SR^  #{ch[:se_sr_ru]}%\n"\
                            "SR   #{ch[:se_sr]}% \n"\
                            "R^   #{ch_verbose[:se_r_ru]}%\n"\
                            "R    #{ch_verbose[:se_r]}%```")
          end

          if verbose
            e.add_field(name: 'CE Chances (^rateup)',
                        value:
                            "```SSR^ #{ch[:ce_ssr_ru]}%\n"\
                            "SSR  #{ch_verbose[:ce_ssr]}%\n"\
                            "SR^  #{ch[:ce_sr_ru]}% \n"\
                            "SR   #{ch_verbose[:ce_sr]}%\n"\
                            "R^   #{ch_verbose[:ce_r_ru]}%\n"\
                            "R    #{ch_verbose[:ce_r]}%```")
          end
        end
      end
    end
  end
end
