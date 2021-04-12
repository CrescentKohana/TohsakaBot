# frozen_string_literal: true

module TohsakaBot
  module Async
    module RefreshStatus
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
