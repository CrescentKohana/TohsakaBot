# frozen_string_literal: true

require 'active_support/core_ext/time'

module TohsakaBot
  module TimeHelper
    def match_time(time, regex)
      return nil if time.nil? || regex.nil?

      time.scan(regex)[0][0].to_i if time.match(regex)
    end
  end

  TohsakaBot.extend TimeHelper
end
