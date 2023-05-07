# frozen_string_literal: true

require 'benchmark'

module TohsakaBot
  module CommandLogic
    class FGO
      def initialize(event, currency, currency_type, verbose)
        @event = event
        # 30SQ is the cost of multi summon (11) in FGO JP as of 2021/05/25.
        @currency = Integer(currency, exception: false) ? currency.to_i : 30
        @currency_type = currency_type
        @verbose = verbose
      end

      def summon_prob(rolls, chance)
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

      def run
        if @currency_type.nil?
          rolls = (@currency / 3)
          rolls += rolls / 10
          @currency_type = 'SQ'
        else
          case @currency_type
          when 'SQ'
            rolls = (@currency / 3).to_i
          when 'USD'
            rolls = (@currency * ((168.0 / 79.99) / 3)).to_i
          when 'JPY'
            rolls = (@currency * ((168.0 / 10_000) / 3)).to_i
          when 'R'
            rolls = @currency
          else
            return I18n.t(:'commands.fun.fgo.error.type')
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

        # Calculate everything to a hash 'c'
        time = Benchmark.measure do
          ch.each { |k, v| ch[k] = summon_prob(rolls, v.to_f) }
          ch_verbose.each { |k, v| ch_verbose[k] = summon_prob(rolls, v.to_f) } if @verbose
        end

        builder = Discordrb::Webhooks::Builder.new
        builder.add_embed do |e|
          e.title = 'Fate/Grand Order 召喚'
          e.colour = 0x032046
          e.description = 'Verbose' if @verbose
          e.footer = Discordrb::Webhooks::EmbedFooter.new(
            text: "#{@currency}#{@currency_type} | #{rolls} roll#{'s' if rolls > 1} | #{time.real.round(4)}s",
            icon_url: 'https://vignette.wikia.nocookie.net/fategrandorder/images/f/ff/Saintquartz.png/revision/latest/'
          )

          unless @verbose
            e.add_field(name: 'Chances (^rateup)',
                        value: "```SSR^ #{ch[:se_ssr_ru]}%\n"\
                               "SSR  #{ch[:se_ssr]}%\n"\
                               "SR^  #{ch[:se_sr_ru]}%\n"\
                               "SR   #{ch[:se_sr]}%\n"\
                               "SSR^ #{ch[:ce_ssr_ru]}% (CE)```")
          end

          if @verbose
            e.add_field(name: 'Servant Chances (^rateup)',
                        value: "```SSR^ #{ch[:se_ssr_ru]}%\n"\
                               "SSR  #{ch[:se_ssr]}%\n"\
                               "SR^  #{ch[:se_sr_ru]}%\n"\
                               "SR   #{ch[:se_sr]}% \n"\
                               "R^   #{ch_verbose[:se_r_ru]}%\n"\
                               "R    #{ch_verbose[:se_r]}%```")
          end

          if @verbose
            e.add_field(name: 'CE Chances (^rateup)',
                        value: "```SSR^ #{ch[:ce_ssr_ru]}%\n"\
                               "SSR  #{ch_verbose[:ce_ssr]}%\n"\
                               "SR^  #{ch[:ce_sr_ru]}% \n"\
                               "SR   #{ch_verbose[:ce_sr]}%\n"\
                               "R^   #{ch_verbose[:ce_r_ru]}%\n"\
                               "R    #{ch_verbose[:ce_r]}%```")
          end
        end

        { content: nil, embeds: builder.embeds.map(&:to_hash) }
      end
    end
  end
end
