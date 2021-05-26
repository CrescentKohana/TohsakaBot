# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class ReminderDetails
      def initialize(event, id, verbose)
        @event = event
        @id = Integer(id, exception: false).nil? ? nil : id
        @verbose = verbose.nil? ? false : true
      end

      def run
        return { content: "Specified reminder wasn't found.", embeds: nil } if @id.nil?

        user_id = TohsakaBot.get_user_id(@event.user.id.to_i).to_i
        reminder = TohsakaBot.db[:reminders].where(id: @id.to_i, user_id: user_id).single_record!
        return { content: "Specified reminder wasn't found.", embeds: nil } if reminder.nil?

        channel = BOT.channel(reminder[:channel_id].to_i)
        channel = channel.nil? ? "" : "Channel: #{channel.name}"
        repeat_time = if reminder[:repeat].zero?
                        ""
                      else
                        distance_of_time_in_words(reminder[:repeat]).to_s
                      end

        builder = Discordrb::Webhooks::Builder.new
        builder.add_embed do |e|
          e.colour = 0xA82727
          e.add_field(name: "When <ID: #{@id}>", value: (reminder[:datetime]).to_s)
          unless reminder[:message].nil? || reminder[:message].empty?
            e.add_field(name: 'Message', value: reminder[:message].to_s)
          end
          e.add_field(name: 'Repeat', value: repeat_time) unless repeat_time.empty?
          e.add_field(name: 'Created At', value: reminder[:created_at].to_s) if @verbose
          e.add_field(name: 'Updated At', value: reminder[:updated_at].to_s) if @verbose
          e.footer = Discordrb::Webhooks::EmbedFooter.new(text: channel)
        end

        { content: nil, embeds: builder.embeds.map(&:to_hash) }
      end
    end
  end
end
