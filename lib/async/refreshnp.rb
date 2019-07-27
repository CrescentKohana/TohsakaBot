module TohsakaBot
  module Async
    module RefreshNP
      Thread.new do
        loop do
          playing = $settings['np']
          # 0 is Playing and anything else is Streaming
          if playing[0] != 0
            BOT.stream(playing[1].to_s, playing[0].to_s)
          else
            BOT.game = playing[1].to_s
          end
          sleep(1800)
        end
      end
    end
  end
end
