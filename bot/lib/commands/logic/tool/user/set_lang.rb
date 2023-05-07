# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class SetLang
      def initialize(event, locale)
        @event = event
        @locale = locale
      end

      def run
        user_id = TohsakaBot.command_event_user_id(@event)
        unless %w[en ja fi].include?(@locale)
          return { content: I18n.t(:'commands.tool.user.language.error.locale_not_found',
                                   locale: TohsakaBot.get_locale(user_id)) }
        end

        TohsakaBot.db.transaction do
          TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(user_id)).update(locale: @locale)
        end
        { content: I18n.t(:'commands.tool.user.language.response', locale: TohsakaBot.get_locale(user_id)) }
      end
    end
  end
end
