module TohsakaBot
  module Async
    module PeriodicalMsgDel
      Thread.new do
        loop do
          unless TohsakaBot.expiring_msgs.nil?
            TohsakaBot.expiring_msgs.each do |e|
              puts e.msg.timestamp + e.duration
              puts Time.now
              if e.msg.timestamp + e.duration > Time.now
                e.msg.delete
              end
            end
          end
          puts "ou jee"
          sleep(5)
        end
      end
    end
  end
end
