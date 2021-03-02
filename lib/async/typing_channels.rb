module TohsakaBot
  module Async
    module TypingChannels
      Thread.new do
        loop do
          TohsakaBot.typing_channels&.each do |k, v|
            if v.nil?
              k.start_typing
            elsif v.positive?
              k.start_typing
              new_duration = v - 4

              if new_duration <= 0
                TohsakaBot.typing_channels.delete(k)
                next
              end

              TohsakaBot.typing_channels[k] = v - 4
            end
          end
          sleep(4)
        end
      end
    end
  end
end
