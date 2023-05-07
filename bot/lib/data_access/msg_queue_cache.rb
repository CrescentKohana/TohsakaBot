# frozen_string_literal: true

module TohsakaBot
  class MsgQueueCache
    attr_accessor :list

    def initialize
      @list = {}
    end

    def add_msg(message, channel, user, embed)
      id = hash([channel, user, embed ? 1 : 0])
      if @list[id].nil?
        @list[id] = {}
        @list[id][:msgs] = []
        @list[id][:time] = TohsakaBot.time_now.to_i + 2
        @list[id][:channel_id] = channel
        @list[id][:embed] = embed
      elsif embed && @list[id][:msgs].size == 25
        send_msgs(id)
        return
      else
        @list[id][:time] += 3
      end

      # Show the user that the bot is doing something by sending a typing indicator
      channel = BOT.channel(@list[id][:channel_id])
      channel&.start_typing

      return if embed && @list[id][:msgs].length >= 25 # maximum number of fields in embed

      @list[id][:msgs] << message unless message.nil? || message.blank?
      id
    end

    def send_msgs(id)
      if @list[id][:embed]
        BOT.channel(@list[id][:channel_id]).send_embed do |e|
          e.colour = 0x36393F
          @list[id][:msgs].each do |m|
            e.add_field(name: m[0], value: m[1])
          end
        end
      else
        message = ''
        @list[id][:msgs].each do |m|
          message += "#{m}\n"
        end

        BOT.channel(@list[id][:channel_id]).send_message(message)
      end
      @list.delete(id)
    end

    def hash(array)
      Digest::SHA1.digest(array.join)
    end
  end
end
