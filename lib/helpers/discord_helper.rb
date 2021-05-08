# frozen_string_literal: true

module TohsakaBot
  module DiscordHelper
    # Discord file upload limits. Bot cannot upload anything larger than 8388119 bytes.
    UPLOAD_LIMIT = 8_388_119
    UPLOAD_LIMIT_NITRO = 52_428_308

    attr_accessor :typing_channels

    def manage_typing(channel, duration)
      @typing_channels = {} if @typing_channels.nil?

      if @typing_channels[channel]
        @typing_channels.delete(channel)
        return
      end

      if Integer(duration, exception: false).nil?
        duration = nil
      else
        duration *= 60
      end

      @typing_channels[channel] = duration
    end

    def send_message_with_reaction(cid, emoji, content, msg_ref = nil)
      reply = if msg_ref.nil?
                BOT.send_message(cid.to_i, content)
              else
                BOT.send_message(cid.to_i, content, false, nil, nil, false, msg_ref)
              end

      reply.create_reaction(emoji)
    end

    def send_multiple_msgs(content, where)
      msg_objects = []
      content.each { |c| msg_objects << where.send_message(c) }
      msg_objects
    end

    def expire_msg(event, bot_msgs, user_msg = nil, duration = 120)
      return if event.pm?

      sleep(duration)
      bot_msgs.each(&:delete)
      user_msg&.delete
    end

    def give_temporary_role(event, role_id, user_id, days, reason)
      db_store = YAML::Store.new('data/temporary_roles.yml')
      server_id = event.channel.server.id
      role_id = role_id.to_i

      # If the user already has an entry for the role, this deletes it first.
      # TohsakaBot.delete_temporary_role_db(user_id, role_id)

      # Gives the role to the user unless they have it.
      unless TohsakaBot::BOT.member(event.server, user_id)&.role?(role_id)
        Discordrb::API::Server.add_member_role("Bot #{AUTH.bot_token}", server_id, user_id, role_id)
      end

      days = Integer(days, exception: false)
      days = 7 if days.nil? || !days.between?(1, 365)

      reason = reason.join(' ').sanitize_string

      # Makes a new entry to the database for the user so that the role can be deleted after a set time.
      # Default: 1 week
      db_store.transaction do
        i = 1
        i += 1 while db_store.root?(i)
        db_store[i] = {
          'time' => Time.now,
          'duration' => days,
          'reason' => reason,
          'user' => user_id,
          'server' => server_id,
          'role' => role_id
        }
        db_store.commit
      end
    end

    def delete_temporary_role_db(user_id, role_id)
      db_read = YAML.load_file('data/temporary_roles.yml')
      db_store = YAML::Store.new('data/temporary_roles.yml')

      db_read.each do |k, v|
        next unless role_id == v['role'].to_i && user_id == v['user'].to_i

        db_store.transaction do
          db_store.delete(k)
          db_store.commit
        end
      end
    end

    def allowed_channels(discord_uid)
      possible_channels = []
      user = BOT.user(discord_uid.to_i)

      user_servers(discord_uid).each do |s|
        s.text_channels.each do |c|
          possible_channels << c if user.on(s).permission?(:send_messages, c)
        end
      end

      # Private Message channel with bot
      possible_channels << user.pm

      possible_channels
    end

    def user_servers(discord_uid)
      servers = []

      BOT.servers.each_value do |s|
        s.non_bot_members.each do |m|
          if m.id.to_i == discord_uid.to_i
            servers << s
            break
          end
        end
      end
      servers
    end

    def discord_id_from_mention(input)
      return input.gsub(/[^\d]/, '').to_i unless Integer(input, exception: false)

      input.to_i
    end

    # Discord User ID to binary -> take 35 bits from the left -> convert back to integer ->
    # add 1420070400000 (first second of 2015) -> parse UNIX timestamp (milliseconds).
    #
    # @param discord_uid [Integer]
    #
    # @return [Time] timestamp
    def account_created_date(discord_uid)
      Time.at((discord_uid.to_s(2)[0..34].to_i(2) + 1_420_070_400_000) / 1000)
    end

    # Dynamic wrapper for setting bot's status
    #
    # @param type [String]
    # @param text [String]
    def status(type, text)
      case type
      when "watching"
        BOT.watching = text
      when "listening"
        BOT.listening = text
      when "competing"
        BOT.competing = text
      else
        BOT.game = text
      end
    end
  end

  TohsakaBot.extend DiscordHelper
end
