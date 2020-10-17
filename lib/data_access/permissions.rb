module TohsakaBot
  # User permissions management
  module Permissions
    # Sets permissions to all users with the data from database.
    def set_permissions
      users = TohsakaBot.db[:users].where(!Sequel[:permissions].nil?)
      users.each do |u|
        discord_uid = TohsakaBot.get_discord_id(u[:id])
        BOT.set_user_permission(discord_uid, u[:permissions]) unless u[:permissions].blank? || discord_uid.nil?
      end
    end

    # Returns Discord user IDs of everyone whose permission level is equal or more than specified.
    #
    # @param level [Integer] permission level
    # @return [Array, nil] Discord UIDs (array of integers)
    def get_users_at_perm_level(level)
      users = TohsakaBot.db[:users].where(Sequel[:permissions] >= level.to_i)
      discord_user_ids = []

      users.each do |u|
        discord_uid = TohsakaBot.get_discord_id(u[:id])
        discord_user_ids << discord_uid unless discord_uid.nil?
      end

      return discord_user_ids unless discord_user_ids.empty?
      nil
    end
  end

  TohsakaBot.extend Permissions
end
