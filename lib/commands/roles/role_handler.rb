# frozen_string_literal: true

module TohsakaBot
  class RoleHandler
    class RoleError < StandardError; end

    class RoleNotFound < RoleError
      I18n.t(:'commands.roles.errors.role_not_found')
    end

    class IDNotFound < RoleError
      I18n.t(:'commands.roles.timed_role.errors.id_not_found')
    end

    class RuleForRoleExists < RoleError
      I18n.t(:'commands.roles.timed_role.errors.rule_for_role_exists')
    end

    class TimedRoleError < StandardError; end

    class DayParseError < TimedRoleError
      def message
        I18n.t(:'commands.roles.timed_role.errors.day_syntax')
      end
    end

    class TimeParseError < TimedRoleError
      def message
        I18n.t(:'commands.roles.timed_role.errors.time_syntax')
      end
    end
  end
end
