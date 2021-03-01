module TohsakaBot
  module DiscordHelper
    # Discord file upload limits. Bot cannot upload anything larger than 8388119 bytes.
    UPLOAD_LIMIT = 8388119
    UPLOAD_LIMIT_NITRO = 52428308

    attr_accessor :typing_channels

    @typing_channels

    def manage_typing(channel, duration)
      if @typing_channels.nil?
        @typing_channels = Hash.new
      end

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

    def send_message_with_reaction(cid, emoji, content)
      reply = BOT.send_message(cid.to_i, content)
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
      bot_msgs.each {|m| m.delete}
      user_msg.delete unless user_msg.nil?
    end

    def give_temporary_role(event, role_id, user_id, duration, reason)
      db_store = YAML::Store.new('data/temporary_roles.yml')
      server_id = event.channel.server.id

      # If the user already has an entry for the role, this deletes it first.
      TohsakaBot.delete_temporary_role_db(user_id, role_id)

      # Gives the role to the user unless they have it.
      unless TohsakaBot::BOT.member(event.server, user_id).role?(role_id)
        Discordrb::API::Server.add_member_role("Bot #{AUTH.bot_token}", server_id, user_id, role_id)
      end

      duration = Integer(duration, exception: false)
      duration = 7 if days.nil? || !duration.between?(1, 365)

      reason = reason.join(' ').sanitize_string

      # Makes a new entry to the database for the user so that we can delete the role after a set time (default: a week).
      db_store.transaction do
        i = 1
        i += 1 while db_store.root?(i)
        db_store[i] = {
          'time' => Time.now,
          'duration' => duration,
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
        if role_id == v['role'].to_i && user_id == v['user'].to_i
          db_store.transaction do
            db_store.delete(k)
            db_store.commit
          end
        end
      end
    end

    def allowed_channels(discord_uid)
      possible_channels = []
      user = BOT.user(discord_uid.to_i)

      user_servers(discord_uid).each do |s|
        s.text_channels.each do |c|
          if user.on(s).permission?(:send_messages, c)
            possible_channels << c
          end
        end
      end

      # Private Message channel with bot
      possible_channels << user.pm

      possible_channels
    end

    def user_servers(discord_uid)
      servers = []

      BOT.servers.values.each do |s|
        s.non_bot_members.each do |m|
          if m.id.to_i == discord_uid.to_i
            servers << s
            break
          end
        end
      end
      servers
    end
  end

  TohsakaBot.extend DiscordHelper
end
