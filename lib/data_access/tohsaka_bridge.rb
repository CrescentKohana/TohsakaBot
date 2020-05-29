module TohsakaBot
  class TohsakaBridge
    def get_now_playing
      CFG.np
    end

    def save_trigger_file(filename)
      # Add an unique ID at the end of the filename.
      o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
      string = (0...8).map { o[rand(o.length)] }.join
      new_filename = filename.gsub(File.extname(filename), '') + '_' + string + File.extname(filename)

      FileUtils.mv "#{CFG.web_dir}/public/uploads/#{filename}", "triggers/#{new_filename}"
      new_filename
    end

    def channels_user_has_rights_to(discord_uid)
      possible_channels = []

      servers_user_is_in(discord_uid).each do |s|
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
