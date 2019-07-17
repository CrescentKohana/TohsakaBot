module TohsakaBot
  module Events
    Dir["#{File.dirname(__FILE__)}/events/*.rb"].each { |file| require file }

    # All events listed below are activated and in use.
    @events = [Replies, TouhouCheck, Log,
               Repost, DecodeMsg, SharedEmoji, AnotherRoll]

    def self.include!
      @events.each do |event|
        TohsakaBot::BOT.include!(event)
      end
    end
  end
end