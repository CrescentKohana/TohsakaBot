module TohsakaBot
  module Async
    module RefreshNP
      Thread.new do
        loop do
          playing = $settings['np']
          BOT.game = playing.to_s
          sleep(1800)
        end
      end
    end
  end
end
