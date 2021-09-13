# frozen_string_literal: true

module TohsakaBot
  module Async
    module PollExpirer
      Thread.new do
        loop do
          TohsakaBot.poll_cache.polls.each do |id, poll|
            next if poll[:time].nil? || poll[:time] >= Time.now.to_i

            response = TohsakaBot.poll_cache.stop(id)
            BOT.send_message(
              poll[:channel_id],
              response,
              false,
              nil,
              nil,
              false,
              { message_id: id }
            )
          end
          sleep(1)
        end
      end
    end
  end
end
