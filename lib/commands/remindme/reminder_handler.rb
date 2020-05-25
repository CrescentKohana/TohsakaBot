module TohsakaBot
  class ReminderHandler
    class DatetimeError < StandardError; end
    class DateTimeSyntaxError < DatetimeError
      def message
        "Incorrect datetime syntax.\n`" +
            "remindme <R〇y〇M〇w〇d〇h〇m〇s||time as natural language||ISO8601 etc.. " +
            "(if spaces, use ; after the time)> <msg>`"
      end
    end
    class PastError < DatetimeError
      def message
        "I've yet to master the art of time travelling. Please refrain using past dates!"
      end
    end
    class WeeksMixedError < DatetimeError
      def message
        "Mixing weeks with other date parts (y, M, d) is not allowed."
      end
    end

    class RepeatIntervalError < StandardError; end
    class PrivateRepeatIntervalError < RepeatIntervalError
      def message
        "The interval limit for repeated reminders in PMs is 10 minutes. Reminder aborted."
      end
    end
    class PublicRepeatIntervalError < RepeatIntervalError
      def message
        "The interval limit for repeated reminders in public channels is 12 hours. Reminder aborted."
      end
    end

    class UserLimitReachedError
      def message
        "You've reached the limit for remainders (#{CFG.remainder_limit}). " +
            "Wait for them to expire, or delete them with `delreminder <id(s)>`."
      end
    end

    def self.handle_user_limit(discord_uid)
      raise UserLimitReachedError if TohsakaBot.user_limit_reached?(discord_uid, CFG.reminder_limit, :reminders)
    end

    def self.handle_repeat_limit(interval_seconds, is_pm)
      raise PrivateRepeatIntervalError if interval_seconds.to_i < 600 && is_pm
      raise PublicRepeatIntervalError if interval_seconds.to_i < 43200 && !is_pm
    end

  end
end
