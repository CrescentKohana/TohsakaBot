# frozen_string_literal: true

TimezoneKeys = ActiveSupport::TimeZone::MAPPING.values.map(&:downcase).freeze

module TohsakaBot
  module CommandLogic
    class SetTimezone
      def initialize(event, timezone)
        @event = event
        @timezone = timezone.is_a?(String) ? timezone : timezone.value
      end

      def run
        user_id = TohsakaBot.command_event_user_id(@event)
        unless TimezoneKeys.include? @timezone.downcase
          return { content: I18n.t(:'commands.tool.user.set_timezone.error.tz_not_found',
                                   locale: TohsakaBot.get_locale(user_id)) }
        end

        TohsakaBot.db.transaction do
          TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(user_id)).update(timezone: @timezone)
        end
        { content: I18n.t(:'commands.tool.user.set_timezone.response', timezone: @timezone) }
      end
    end
  end
end
