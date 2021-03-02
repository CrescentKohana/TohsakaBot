module TohsakaBot
  module Async
    module MsgQueueHelper
      Thread.new do
        loop do
          TohsakaBot.queue_cache.list.each do |k, v|
            TohsakaBot.queue_cache.send_msgs(k) if v[:time] <= Time.now.to_i || (v[:embed] && v[:msgs].size == 25)
          end
          sleep(1)
        end
      end
    end
  end
end

