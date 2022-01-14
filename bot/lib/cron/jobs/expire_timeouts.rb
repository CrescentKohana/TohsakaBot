# frozen_string_literal: true

module TohsakaBot
  module Jobs
    def self.expire_timeouts(now)
      TohsakaBot.timeouts_cache.timeouts.each do |id, timeout|
        if (timeout[:created_at].to_i + 60 * 10) < now.to_i
          TohsakaBot.timeouts_cache.timeouts.delete(id)
          next
        end
        TohsakaBot.timeouts_cache.stop(id) if TohsakaBot.timeouts_cache.total_votes(id) >= 1
      end
    end
  end
end
