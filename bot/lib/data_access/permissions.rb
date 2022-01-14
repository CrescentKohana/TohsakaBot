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

      set_all
    end

    # Sets user's permission level (0-1000)
    #
    # @param discord_uid [Integer] discord user id
    # @param level [Integer] permission level (0-1000)
    # @return [nil] if failed
    def set_level(discord_uid, level)
      # Do not allow editing owner's permission level under any circumstances.
      return if discord_uid.to_i == AUTH.owner_id.to_i

      user_id = TohsakaBot.get_user_id(discord_uid.to_i)

      # 1000 is reserved for the owner.
      return nil if !(0..999).include?(level.to_i) || user_id.nil?

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

    # Returns true if user is at the level of permissions specified or higher.
    #
    # @param discord_id [Integer] discord user id
    # @param permission [Integer, String] permission level or type as string, determined by type
    # @param type [Symbol] :role (string), :perm (string), :level (integer)
    # @return [Boolean] permission or not
    def able?(discord_id, permission, type)
      level = case type
              when :level
                permission.to_i
              when :perm
                @actions[permission]
              when :role
                @roles[permission]
              end
      level = Integer(level, exception: false).nil? ? 0 : level.clamp(0, 1000)

      users_with_permissions = TohsakaBot.permissions.users_at_level(level)
      return false if users_with_permissions.nil?

      users_with_permissions.include?(discord_id)
    end

    def allowed_role(discord_id, server_id, role)
      return nil if role.nil?

      roles = TohsakaBot.server_cache[server_id][:roles]
      if !Integer(role, exception: false).nil? && (roles[role.to_i][:permissions].zero? ||
        able?(discord_id, roles[role.to_i][:permissions], :level))
        return id
      end

      role = role.downcase
      roles.each do |role_id, role_data|
        if role_data[:name].downcase == role && (role_data[:permissions].zero? ||
          able?(discord_id, role_data[:permissions], :level))
          return role_id
        end
      end

      nil
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
