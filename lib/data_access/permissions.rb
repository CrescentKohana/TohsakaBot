# frozen_string_literal: true

module TohsakaBot
  # User permissions management
  class Permissions
    attr_accessor :roles, :actions

    def initialize
      permissions = JSON.parse(File.read('data/persistent/permissions.json'))
      @roles = permissions["roles"]
      @actions = {}

      permissions["actions"].each do |action, role|
        @actions[action] = permissions["roles"][role]
      end

      TohsakaBot.db[:users].where(!Sequel[:permissions].nil?).each do |u|
        discord_uid = TohsakaBot.get_discord_id(u[:id])
        BOT.set_user_permission(discord_uid, u[:permissions]) unless u[:permissions].blank? || discord_uid.nil?
      end

      set_all
    end

    # Sets user's permission level (0-1000)
    #
    # @param discord_uid [Integer] discord user id
    # @param level [Integer] permission level (0-1000)
    # @return [nil] if failed
    def set_level(discord_uid, level)
      user_id = TohsakaBot.get_user_id(discord_uid.to_i)

      return nil if !(0..1000).include?(level.to_i) || user_id.nil?

      TohsakaBot.db.transaction do
        TohsakaBot.db[:users].where(id: user_id.to_i).update(permissions: level.to_i)
      end
      BOT.set_user_permission(discord_uid, level)
    end

    # Returns Discord user IDs of everyone whose permission level is equal or more than specified.
    #
    # @param level [Integer] permission level
    # @return [Array, nil] Discord UIDs (array of integers)
    def users_at_level(level)
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
      users_with_permissions = TohsakaBot.permissions.users_at_level(level)
      return false if users_with_permissions.nil?

      users_with_permissions.include?(discord_id)
    end

    private

    # Sets permissions to all users using the data from the database.
    def set_all
      users = TohsakaBot.db[:users].where(!Sequel[:permissions].nil?)
      users.each do |u|
        discord_uid = TohsakaBot.get_discord_id(u[:id])
        BOT.set_user_permission(discord_uid, u[:permissions]) unless u[:permissions].blank? || discord_uid.nil?
      end

      # Owner's permission level is always 1000.
      BOT.set_user_permission(AUTH.owner_id.to_i, 1000)
    end
  end
end
