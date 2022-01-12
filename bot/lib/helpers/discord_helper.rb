# frozen_string_literal: true

module TohsakaBot
  module DiscordHelper
    # Discord file upload limits.
    UPLOAD_LIMIT = 8_388_119
    UPLOAD_LIMIT_BOOST_L2 = 52_428_308
    UPLOAD_LIMIT_BOOST_L3 = 104_856_616

    attr_accessor :typing_channels

    def server_upload_limit(server_id)
      server = BOT.server(server_id.to_i)
      return UPLOAD_LIMIT if server.nil?

      case server.boost_level
      when 2
        UPLOAD_LIMIT_BOOST_L2
      when 3
        UPLOAD_LIMIT_BOOST_L3
      else
        UPLOAD_LIMIT
      end
    end

    def manage_typing(channel, duration)
      @typing_channels = {} if @typing_channels.nil?

      if @typing_channels[channel]
        @typing_channels.delete(channel)
        return
      end

      if Integer(duration, exception: false)
        duration *= 60
      else
        duration = nil
      end

      @typing_channels[channel] = duration
    end

    def send_message_with_reaction(channel_id, emoji, content, msg_ref = nil)
      reply = if msg_ref.nil?
                BOT.send_message(channel_id.to_i, content)
              else
                BOT.send_message(channel_id.to_i, content, false, nil, nil, false, msg_ref)
              end

      reply.create_reaction(emoji)
    end

    def send_multiple_msgs(content, where)
      msg_objects = []
      content.each { |c| msg_objects << where.send_message(c) }
      msg_objects
    end

    def expire_msg(event, bot_msgs, user_msg = nil, duration = 300)
      return if event.pm?

      sleep(duration)
      bot_msgs.each(&:delete)
      user_msg&.delete
    end

    def give_trophy(event, winner, user_id, days, reason)
      server_id = event.channel.server.id
      role_id = winner ? CFG.mvp_role.to_i : CFG.fool_role.to_i

      # Gives the role to the user unless they already have it.
      unless TohsakaBot::BOT.member(event.server, user_id)&.role?(role_id)
        Discordrb::API::Server.add_member_role("Bot #{AUTH.bot_token}", server_id, user_id, role_id)
      end

      days = Integer(days, exception: false)
      days = 7 if days.nil? || !days.between?(1, 365)
      reason = reason.join(' ').sanitize_string

      # Makes a new entry to the database for the user so that the role can be deleted after a set time.
      trophies = TohsakaBot.db[:trophies]
      TohsakaBot.db.transaction do
        now = Time.now
        @id = trophies.insert(
          reason: reason,
          duration: days,
          category: winner ? 1 : 2,
          discord_uid: user_id,
          server_id: server_id,
          role_id: role_id,
          created_at: now,
          updated_at: now
        )
      end
    end

    def command_event_user_id(event, return_id: true)
      if event.instance_of?(Discordrb::Events::ApplicationCommandEvent)
        return_id ? event.user.id : event.user
      else # Discordrb::Commands::CommandEvent
        return_id ? event.message.user.id : event.message.user
      end
    end

    def allowed_channels(discord_uid)
      possible_channels = []
      user = BOT.user(discord_uid.to_i)

      user_servers(discord_uid).each do |server|
        next if server.nil?

        server.text_channels.each do |channel|
          next if channel.nil?

          possible_channels << channel if user&.on(server)&.permission?(:send_messages, channel)
        end
      end

      # Private Message channel with bot
      possible_channels << user.pm

      possible_channels
    end

    def user_servers(discord_uid)
      servers = []

      BOT.servers.each_value do |server|
        servers << server unless server.member(discord_uid).nil?
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
      return nil if discord_uid.nil?

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

    # Trim Discord message's length. Default max length is 2000.
    #
    # @param content [String]
    # @param fixed_length [Integer]
    # @param max_length [Integer]
    def trim_message(content, fixed_length: 0, max_length: 2000)
      max_content_length = max_length - fixed_length
      content.slice(0, max_content_length)
    end

    def read_servers
      servers = JSON.parse(File.read("data/servers.json"))["servers"]

      servers_hash = {}
      servers.each do |server|
        server_response = BOT.server(server["id"])
        next unless server_response

        roles_hash = {}
        server["roles"].each do |role|
          # Skip roles that don't exist
          next unless server_response.roles.find { |r| r.id == role["id"] }

          roles_hash[role["id"]] = {
            name: role["name"],
            group_size: role["group_size"],
            permissions: role["permissions"]
          }
        end

        servers_hash[server["id"]] = {
          name: server["name"],
          default_channel: server["default_channel"],
          highlight_channel: server["highlight_channel"],
          mvp_role: server["mvp_role"],
          fool_role: server["fool_role"],
          daily_neko: server["daily_neko"],
          roles: roles_hash
        }
      end

      servers_hash
    end
  end

  TohsakaBot.extend DiscordHelper
end
