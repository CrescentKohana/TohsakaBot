# frozen_string_literal: true

module TohsakaBot
  module Async
    module URLCleaner
      # Removes three days old links from repost db.
      Thread.new do
        loop do
          TohsakaBot.db[:linkeds].where(Sequel[:timestamp].to_i + (72 * 60 * 60) <= Time.now.to_i).delete
          sleep(3600)
        end
      end
    end
  end
end
