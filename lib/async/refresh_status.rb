# frozen_string_literal: true

module TohsakaBot
  module Async
    module RefreshStatus
      Thread.new do
        loop do
          cfg = YAML.load_file('cfg/config.yml')
          TohsakaBot.status(cfg["status"][0], cfg["status"][1])
          sleep(1800)
        end
      end
    end
  end
end
