# frozen_string_literal: true

module Discordrb
  # Objects specific to Interactions.
  module Interactions

    # A builder for defining slash commands options.
    class OptionBuilder
      # @!visibility private
      TYPES = {
        subcommand: 1,
        subcommand_group: 2,
        string: 3,
        integer: 4,
        boolean: 5,
        user: 6,
        channel: 7,
        role: 8,
        mentionable: 9,
        number: 10
      }.freeze

      # Channel types that can be provided to #channel
      CHANNEL_TYPES = {
        text: 0,
        dm: 1,
        voice: 2,
        group_dm: 3,
        category: 4,
        news: 5,
        store: 6,
        news_thread: 10,
        public_thread: 11,
        private_thread: 12,
        stage: 13
      }.freeze

      # @return [Array<Hash>]
      attr_reader :options

      # @!visibility private
      def initialize
        @options = []
      end

      # @param name [String, Symbol] The name of the subcommand.
      # @param description [String] A description of the subcommand.
      # @yieldparam [OptionBuilder]
      # @return (see #option)
      # @example
      #   bot.register_application_command(:test, 'Test command') do |cmd|
      #     cmd.subcommand(:echo) do |sub|
      #       sub.string('message', 'What to echo back', required: true)
      #     end
      #   end
      def subcommand(name, description)
        builder = OptionBuilder.new
        yield builder if block_given?

        option(TYPES[:subcommand], name, description, options: builder.to_a)
      end

      # @param name [String, Symbol] The name of the subcommand group.
      # @param description [String] A description of the subcommand group.
      # @yieldparam [OptionBuilder]
      # @return (see #option)
      # @example
      #   bot.register_application_command(:test, 'Test command') do |cmd|
      #     cmd.subcommand_group(:fun) do |group|
      #       group.subcommand(:8ball) do |sub|
      #         sub.string(:question, 'What do you ask the mighty 8ball?')
      #       end
      #     end
      #   end
      def subcommand_group(name, description)
        builder = OptionBuilder.new
        yield builder

        option(TYPES[:subcommand_group], name, description, options: builder.to_a)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @param choices [Hash, nil] Available choices, mapped as `Name => Value`.
      # @return (see #option)
      def string(name, description, required: nil, choices: nil)
        option(TYPES[:string], name, description, required: required, choices: choices)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @param choices [Hash, nil] Available choices, mapped as `Name => Value`.
      # @return (see #option)
      def integer(name, description, required: nil, min_value: nil, max_value: nil, choices: nil)
        option(TYPES[:integer], name, description, required: required, min_value: min_value, max_value: max_value, choices: choices)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @return (see #option)
      def boolean(name, description, required: nil)
        option(TYPES[:boolean], name, description, required: required)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @return (see #option)
      def user(name, description, required: nil)
        option(TYPES[:user], name, description, required: required)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @param types [Array<Symbol, Integer>] See {CHANNEL_TYPES}
      # @return (see #option)
      def channel(name, description, required: nil, types: nil)
        types = types&.collect { |type| type.is_a?(Numeric) ? type : CHANNEL_TYPES[type] }
        option(TYPES[:channel], name, description, required: required, channel_types: types)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @return (see #option)
      def role(name, description, required: nil)
        option(TYPES[:role], name, description, required: required)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @return (see #option)
      def mentionable(name, description, required: nil)
        option(TYPES[:mentionable], name, description, required: required)
      end

      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @return (see #option)
      def number(name, description, required: nil, min_value: nil, max_value: nil, choices: nil)
        option(TYPES[:number], name, description,
               required: required, min_value: min_value, max_value: max_value, choices: choices)
      end

      # @!visibility private
      # @param type [Integer] The argument type.
      # @param name [String, Symbol] The name of the argument.
      # @param description [String] A description of the argument.
      # @param required [true, false] Whether this option must be provided.
      # @param min_value [Integer, Float] A minimum value for integer and number options.
      # @param max_value [Integer, Float] A maximum value for integer and number options.
      # @param channel_types [Array<Integer>] Channel types that can be provides for channel options.
      # @return Hash
      def option(type, name, description, required: nil, choices: nil, options: nil, min_value: nil, max_value: nil,
                 channel_types: nil)
        opt = { type: type, name: name, description: description }
        choices = choices.map { |option_name, value| { name: option_name, value: value } } if choices

        opt.merge!({ required: required, choices: choices, options: options, min_value: min_value,
                     max_value: max_value, channel_types: channel_types }.compact)

        @options << opt
        opt
      end

      # @return [Array<Hash>]
      def to_a
        @options
      end
    end

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

      # @return [Array<Component>]
      attr_reader :components

      # @!visibility private
      def initialize(data, bot, interaction)
        @data = data
        @bot = bot
        @interaction = interaction
        @content = data['content']
        @channel_id = data['channel_id'].to_i
        @pinned = data['pinned']
        @tts = data['tts']

        @message_reference = data['message_reference']

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
        @components = data['components'].map { |component_data| Components.from_data(component_data, @bot) } if data['components']
      end
    end
  end
end
