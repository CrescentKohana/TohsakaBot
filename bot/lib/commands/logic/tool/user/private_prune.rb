# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class PrivatePrune
      def initialize(event, amount)
        @event = event
        @amount = amount
      end

      def run
        unless @event.channel.pm? && @event.channel.recipient.id == @event.message.author.id
          return { content: I18n.t(:'commands.tool.user.private_prune.error.only_pm') }
        end

        unless /\A\d+\z/.match(@amount) && (2..100).include?(@amount.to_i)
          return { content: 'The amount of messages has to be between 2 and 100.' }
        end

        # Sadly bulk delete can't be used in private messages (2021/09/12):
        # https://discord.com/developers/docs/resources/channel#bulk-delete-messages
        deleted_count = 0
        @event.channel.history(@amount).each do |m|
          # Message has to be from this bot and the message can't be older than 2 weeks (+ a 5 minutes buffer)
          if m.author.id == AUTH.cli_id && (14 * 24 * 60 - 5).minutes.ago <= m.timestamp
            m.delete
            deleted_count += 1
          end
        end

        { content: I18n.t(:'commands.tool.user.private_prune.response', deleted_count: deleted_count) }
      end
    end
  end
end
