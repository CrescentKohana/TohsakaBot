# frozen_string_literal: true

module Discordrb
  # Objects specific to Interactions.
  module Interactions

    # A message partial for interactions.
    class Message
      include IDObject

      # @return [Interaction] The interaction that created this message.
      attr_reader :interaction

      # @return [String, nil] The content of the message.
      attr_reader :content

      # @return [true, false] Whether this message is pinned in the channel it belongs to.
      attr_reader :pinned

      # @return [true, false]
      attr_reader :tts

      # @return [Time]
      attr_reader :timestamp

      # @return [Time, nil]
      attr_reader :edited_timestamp

      # @return [true, false]
      attr_reader :edited

      # @return [Integer]
      attr_reader :id

      # @return [User] The user of the application.
      attr_reader :author

      # @return [Attachment]
      attr_reader :attachments

      # @return [Array<Embed>]
      attr_reader :embeds

      # @return [Array<User>]
      attr_reader :mentions

      # @return [Integer]
      attr_reader :flags

      # @return [Integer]
      attr_reader :channel_id

      # @return [Hash, nil]
      attr_reader :message_reference

      # @return [Hash, nil]
      attr_reader :components

      # @!visibility private
      def initialize(data, bot, interaction)
        @bot = bot
        @interaction = interaction
        @content = data['content']
        @channel_id = data['channel_id'].to_i
        @pinned = data['pinned']
        @tts = data['tts']

        @message_reference = data['message_reference']

        # Added components
        @components = data['components']

        @server_id = data['guild_id']&.to_i

        @timestamp = Time.parse(data['timestamp']) if data['timestamp']
        @edited_timestamp = data['edited_timestamp'].nil? ? nil : Time.parse(data['edited_timestamp'])
        @edited = !@edited_timestamp.nil?

        @id = data['id'].to_i

        @author = bot.ensure_user(data['author'] || data['member']['user'])

        @attachments = []
        @attachments = data['attachments'].map { |e| Attachment.new(e, self, @bot) } if data['attachments']

        @embeds = []
        @embeds = data['embeds'].map { |e| Embed.new(e, self) } if data['embeds']

        @mentions = []

        data['mentions']&.each do |element|
          @mentions << bot.ensure_user(element)
        end

        @mention_roles = data['mention_roles']
        @mention_everyone = data['mention_everyone']
        @flags = data['flags']
        @pinned = data['pinned']
      end
    end
  end
end
