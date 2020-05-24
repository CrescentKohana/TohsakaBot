module TohsakaBot
  class TohsakaBridge
    def get_current_time
      Time.now
    end

    def get_now_playing
      CFG.np
    end

    def channels_user_has_rights_to(discord_uid)
      possible_channels = []
      bot_servers = BOT.servers

      bot_servers.values.each do |s|
        user = BOT.user(discord_uid.to_i).on(s)
        s.text_channels.each do |c|
          # TODO: Possible bug in the library: https://github.com/discordrb/discordrb/pull/712
          if user.permission?(:send_messages, c)
            possible_channels << c
          end
        end
      end

      possible_channels
    end

    def get_channel(id)
      BOT.channel(id)
    end

    # Checks that the member is in same server as the bot.
    # Used to prevent any outsiders creating accounts.
    def share_server_with_bot?(id)
      BOT.servers.each do |s|
        s.second.members.each do |m|
          return true if m.id.to_i == id.to_i
        end
      end
      false
    end
  end
end
