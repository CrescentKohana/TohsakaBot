# frozen_string_literal: true

module TohsakaBot
  module Async
    # Removes 3d (72h * 60m * 60s) old links and file hashes.
    module URLCleaner
      Thread.new do
        loop do
          TohsakaBot.db[:linkeds].where(Sequel[:timestamp] >= Time.now - (72 * 60 * 60)).delete
          sleep(3600)
        end
      end
    end
  end
end
