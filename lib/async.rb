# frozen_string_literal: true

module TohsakaBot
  module Async
    Dir["#{File.dirname(__FILE__)}/async/*.rb"].sort.each { |file| require file }

    # All asynchronous events listed below are activated and in use.
    @async = [RefreshStatus, RemindOnTime, RepostCleaner, RoleManagement, LoadAlko]

    def self.include!
      @async.each do |event|
        TohsakaBot::BOT.include!(event)
      end
    end
  end
end
