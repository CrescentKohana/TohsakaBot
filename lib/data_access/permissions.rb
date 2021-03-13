# frozen_string_literal: true

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

    # Sets user's permission level (0-1000)
    #
    # @param discord_id [Integer] discord user id
    # @param level [Integer] permission level (0-1000)
    # @return [nil] if failed
    def set_permission(discord_id, level)
      user_id = get_user_id(discord_id.to_i)

      return nil if !(0..1000).include?(level.to_i) || user_id.nil?

      TohsakaBot.db.transaction do
        TohsakaBot.db[:users].where(id: user_id.to_i).update(permissions: level.to_i)
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

    # Returns true if user is at the level of permissions specified or higher
    #
    # @param discord_id [Integer] discord user id
    # @param level [Integer] permission level
    # @return [Boolean] permission or not
    def permission?(discord_id, level)
      users_with_permissions = TohsakaBot.get_users_at_perm_level(level)
      return false if users_with_permissions.nil?

      users_with_permissions.include?(discord_id)
    end
  end

  TohsakaBot.extend Permissions
end
