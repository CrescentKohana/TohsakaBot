# frozen_string_literal: true

require 'active_support/core_ext/time'

module TohsakaBot
  module TimeHelper
    def match_time(time, regex)
      return nil if time.nil? || regex.nil?

      time.scan(regex)[0][0].to_i if time.match(regex)
    end

    def time_now(tz = nil)
      return Time.now.utc if tz.nil?

      Time.now.in_time_zone(tz)
    rescue ArgumentError
      Time.now.utc
    end

    # Returns user's time.
    #
    # @param id [Integer, nil] Internal user ID
    # @param discord [Boolean] is the provided ID Discord UID?
    # @return [Time, ActiveSupport::TimeWithZone] User's time (default: 'UTC')
    def user_time_now(id, discord = false)
      id = TohsakaBot.get_user_id(id.to_i) if discord && !id.nil?
      TohsakaBot.time_now(TohsakaBot.get_timezone(id))
    end
  end

  TohsakaBot.extend TimeHelper
end
