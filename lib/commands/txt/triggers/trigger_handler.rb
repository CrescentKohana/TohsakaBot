# frozen_string_literal: true

module TohsakaBot
  class TriggerHandler
    class TriggerError < StandardError; end

    class NoRegexPermissions < TriggerError
      def message
        I18n.t(:'commands.trigger.errors.regex_permissions')
      end
    end

    class ExactTriggerAlreadyExists < TriggerError
      def initialize(phrase)
        super
        @phrase = phrase
      end

      def message
        I18n.t(:'commands.trigger.errors.exact_trigger_already_exists', phrase: @phrase)
      end
    end

    class UserLimitReachedError
      def message
        I18n.t(:'commands.trigger.errors.trigger_limit', limit: CFG.trigger_limit)
      end
    end

    def self.handle_user_limit(discord_uid)
      raise UserLimitReachedError if TohsakaBot.user_limit_reached?(discord_uid, CFG.trigger_limit, :triggers)
    end

    def self.regex_permissions?(discord_uid)
      return unless TohsakaBot.permissions.able?(discord_uid, "regex_triggers", :perm)

      raise NoRegexPermissions
    end
  end
end
