module TohsakaBot
  module Async
    Dir["#{File.dirname(__FILE__)}/async/*.rb"].sort.each { |file| require file }

    # All asynchronous events listed below are activated and in use.
    @async = [RefreshNP, RemindOnTime, URLCleaner, PeriodicalTempRoleDeletion, LoadAlko]

    def self.include!
      @async.each do |event|
        TohsakaBot::BOT.include!(event)
      end
    end
  end
end
