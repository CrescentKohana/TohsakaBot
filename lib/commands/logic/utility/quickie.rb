# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Quickie
      def self.duration(seconds)
        seconds = seconds.to_i
        return seconds if (1..10).include? seconds

        5
      end
    end
  end
end
