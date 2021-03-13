# frozen_string_literal: true

module TohsakaBot
  class TohsakaBridge
    def online?(faking = false)
      faking ? false : true
    end

    def get_now_playing
      CFG.np
    end

    def save_trigger_file(path, filename)
      FileUtils.mv path, "data/triggers/#{filename}"
    end

    def reload_triggers
      TohsakaBot.trigger_data.reload_active
    end

    def channels_user_has_rights_to(discord_uid)
      TohsakaBot.allowed_channels(discord_uid)
    end

    def servers_user_is_in(discord_uid)
      TohsakaBot.user_servers(discord_uid)
    end

    def get_user(user_discord_id)
      user = BOT.user(user_discord_id.to_i)
      user if user.is_a? Discordrb::User
      nil
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
      if mode.to_i.zero?
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
