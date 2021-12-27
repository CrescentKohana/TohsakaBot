# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Coinflip
      def initialize(event, times)
        @event = event
        @times = times.to_i
      end

      def run
        # Let's try to keep the CPU intact while we're at it.
        return I18n.t(:'commands.fun.coinflip.error.times') if @times > 100_000

        user_id = TohsakaBot.command_event_user_id(@event)

        # Probabilities for the coin toss (%).
        coin = {
          I18n.t(:'commands.fun.coinflip.outcome.tails') => 49,
          I18n.t(:'commands.fun.coinflip.outcome.heads') => 49,
          I18n.t(:'commands.fun.coinflip.outcome.edge') => 2
        }
        coin_toss = Pickup.new(coin)

        msg_ref = nil # Discordrb::Events::ApplicationCommandEvent
        msg_ref = @event.message if @event.instance_of?(Discordrb::Commands::CommandEvent)

        if @times > 1
          coins = coin_toss.pick(@times)
          c = coins.uniq.map { |x| [x, coins.count(x)] }.to_h

          {
            content: "`#{c.keys[0]}: #{c.values[0]}` `#{c.keys[1]}: #{c.values[1]}` `#{c.keys[2]}: #{c.values[2]}`",
            embeds: nil,
            reference: msg_ref
          }
        else
          picked = coin_toss.pick(1)

          if picked == I18n.t(:'commands.fun.coinflip.outcome.edge')
            TohsakaBot.give_trophy(@event, true, user_id, 1, 'Flipped a coin on its edge')
          end

          case picked
          when I18n.t(:'commands.fun.coinflip.outcome.tails')
            url = 'https://cdn.discordapp.com/attachments/351170098754486289/655844541844291584/tails.png'
          when I18n.t(:'commands.fun.coinflip.outcome.heads')
            url = 'https://cdn.discordapp.com/attachments/351170098754486289/655844590896807966/heads.png'
          else
            url = ''
            picked = "| #{picked}"
          end

          builder = Discordrb::Webhooks::Builder.new
          builder.add_embed do |e|
            e.colour = 0xA82727
            e.author = Discordrb::Webhooks::EmbedAuthor.new(name: picked, icon_url: url)
          end

          { content: nil, embeds: builder.embeds.map(&:to_hash), reference: msg_ref }
        end
      end
    end
  end
end
