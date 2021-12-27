# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class RoleReason
      def initialize(event, user, expired: true)
        @event = event
        @user = user
        @expired = expired
      end

      def run
        return { content: I18n.t(:'commands.roles.reason.error.no_user') } if @user.blank?

        trophies = TohsakaBot.db[:trophies]
        given_trophies = if @expired
                           trophies.where(discord_uid: @user, expired: @expired)
                         else
                           trophies.where(discord_uid: @user)
                         end

        return { content: I18n.t(:'commands.roles.reason.error.no_trophies_found') } if given_trophies.blank?

        { content: response[:content], embeds: nil, components: button, error: false }
      end
    end
  end
end
