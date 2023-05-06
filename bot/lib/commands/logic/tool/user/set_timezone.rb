# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class SetTimezone
      def initialize(event, timezone)
        @event = event
        @timezone = timezone
      end

      def run
        user_id = TohsakaBot.command_event_user_id(@event)
        unless ActiveSupport::TimeZone::MAPPING.map(&:lowercase).include? @timezone.lowercase
          return { content: I18n.t(:'commands.tool.user.set_timezone.error.tz_not_found',
                                   locale: TohsakaBot.get_locale(user_id)) }
        end

        TohsakaBot.db.transaction do
          TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(user_id)).update(timezone: @locale)
        end
        { content: I18n.t(:'commands.tool.user.set_timezone.response', timezone: @timezone, locale: TohsakaBot.get_locale(user_id)) }
      end
    end
  end
end
