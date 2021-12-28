# frozen_string_literal: true

module TohsakaBot
  module Jobs
    def self.expire_polls(now)
      TohsakaBot.poll_cache.polls.each do |id, poll|
        next if poll[:time].nil? || poll[:time] >= now.to_i

        response = TohsakaBot.poll_cache.stop(id)
        BOT.send_message(
          poll[:channel_id],
          "",
          false,
          response.embeds.first,
          nil,
          false,
          { message_id: id }
        )
      end
    end
  end
end
