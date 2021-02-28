module TohsakaBot
  module Commands
    module EditPermissions
      extend Discordrb::Commands::CommandContainer
      command(:editpermissions,
              aliases: %i[editperm editpermissions],
              description: "Edits given user's permission level.",
              usage: "listroles <'all' or 'server' to list all the roles in this server>",
              min_args: 2,
              permission_level: 1000) do |event, discord_uid, level|

        discord_uid = discord_uid.to_i
        break if discord_uid == AUTH.owner_id.to_i

        level = level.to_i
        user = BOT.user(discord_uid)

        if user.nil?
          event.respond("The user doesn't exist.")
          break
        end

        if user.nil?
          event.respond("Permission level range: 0 - 1000.")
          break
        end

        succession = TohsakaBot.set_permission(discord_uid, level)
        if succession.nil?
          event.respond("Failed to set permissions for #{user.name}")
        else
          event.respond("Permission level of #{level} set for #{user.name}")
        end
      end
    end
  end
end
