module TohsakaBot
  class TohsakaBridge
    def online?(faking = false)
      faking ? false : true
    end

    def get_now_playing
      CFG.np
    end

    def save_trigger_file(path, filename)
      FileUtils.mv path, "triggers/#{filename}"
    end

    def channels_user_has_rights_to(discord_uid)
      possible_channels = []
      user = BOT.user(discord_uid.to_i)

      servers_user_is_in(discord_uid).each do |s|
        s.text_channels.each do |c|
          # TODO: Possible bug in the library: https://github.com/discordrb/discordrb/pull/712
          if user.on(s).permission?(:send_messages, c)
            possible_channels << c
          end
        end
      end

      # Private Message channel with bot
      possible_channels << user.pm

      possible_channels
    end

    def servers_user_is_in(discord_uid)
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

    def get_channel(channel_id)
      BOT.channel(channel_id.to_i)
    end

    def get_server(server_id)
      BOT.server(server_id.to_i)
    end

    def is_pm?(channel_id)
      BOT.channel(channel_id.to_i).pm?
    end

    def get_def_trigger_chance(mode)
      default_chance = CFG.default_trigger_chance.to_i
      if mode.to_i == 0
        default_chance * 2
      else
        default_chance
      end
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
