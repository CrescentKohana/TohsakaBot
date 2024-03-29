# frozen_string_literal: true

module TohsakaBot
  class TohsakaBridge
    def online?(faking = false)
      faking ? false : true
    end

    def get_now_playing
      CFG.status
    end

    def save_trigger_file(path, filename)
      FileUtils.mv path, CFG.data_dir + "/triggers/#{filename}"
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

    def get_user(discord_uid)
      user = BOT.user(discord_uid.to_i)
      return user if !user.nil? && (user.is_a? Discordrb::User)

      Discordrb::User.new({ 'id' => discord_uid, 'username' => 'Deleted User', 'bot' => false }, BOT)
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

    def parse_chance(chance, mode)
      TohsakaBot.trigger_data.parse_chance(chance, mode)
    end

    def highlight_channel(server_id)
      TohsakaBot.server_cache[server_id][:highlight_channel]
    end

    def default_channel(server_id)
      TohsakaBot.server_cache[server_id][:default_channel]
    end

    def get_server_config(server_id = nil)
      return TohsakaBot.server_cache if server_id.nil?

      TohsakaBot.server_cache[server_id]
    end

    def channel_permission?(server_id, channel_id, discord_uid, action)
      return false if channel_id.blank? || channel_id.zero?

      begin
        member = BOT.member(server_id, discord_uid)
        return false if member.nil?

        member.permission?(action, BOT.channel(channel_id))
      rescue
        false
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
