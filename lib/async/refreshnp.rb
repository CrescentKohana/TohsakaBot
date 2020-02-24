module TohsakaBot
  module Async
    module RefreshNP
      Thread.new do
        loop do
          cfg = YAML.load_file('cfg/config.yml')
          BOT.game = cfg['np']
          sleep(1800)
        end
      end
    end
  end
end
