# frozen_string_literal: true

module TohsakaBot
  module Commands
    module SetPermissions
      extend Discordrb::Commands::CommandContainer
      command(:setpermissions,
              aliases: %i[editperm editpermissions setperm],
              description: "Edits given user's permission level.",
              usage: 'setperm <discord uid> <level (0-1000)>',
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["permissions"]) do |event, user, level|
        discord_user = BOT.user(TohsakaBot.discord_id_from_mention(user))

        if discord_user.nil?
          event.respond("The user doesn't exist.")
          break
        end

        # Do not allow editing owner's permission level under any circumstances.
        break if discord_user.id.to_i == AUTH.owner_id.to_i

        if level.nil? || !(0..1000).include?(level.to_i)
          event.respond('Permission level range: 0 - 1000.')
          break
        end

        success = TohsakaBot.permissions.set_level(discord_user.id, level)
        if success.nil?
          event.respond("Failed to set permissions for #{discord_user.name}")
        else
          event.respond("Permission level of #{level} set for #{discord_user.name}")
        end
      end
    end
  end
end
