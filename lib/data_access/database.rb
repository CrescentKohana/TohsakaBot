module TohsakaBot
  module DatabaseAccess
    def db
      @db ||= Sequel.connect(
          adapter: 'mysql2',
          charset: 'utf8mb4',
          collate: 'utf8mb4_unicode_ci',
          host: AUTH.db_url,
          database: AUTH.db_name,
          user: AUTH.db_user,
          password: AUTH.db_password
      )
    end

    def registered?(discord_uid, event = nil)
      if TohsakaBot.get_user_id(discord_uid.to_i).to_i > 0
        return true
      else
        event.respond "You aren't registered yet! Please do so by entering the command `?register`." unless event.nil?
        return false
      end
    rescue
      event.respond "You aren't registered yet! Please do so by entering the command `?register`." unless event.nil?
      false
    end

    # Not Discord UID
    def get_user_id(discord_uid)
      auths = TohsakaBot.db[:authorizations]
      auths.where(:uid => discord_uid.to_i).first[:user_id].to_i
    end

    # Discord UID
    def get_discord_id(user_id)
      auths = TohsakaBot.db[:authorizations]
      auths.where(:user_id => user_id.to_i).first[:uid].to_i
    end

    # Checks if the user limit is reached for this datatype.
    # For example, if the user has 50 reminders, and the limit is 50, the method returns true.
    #
    # @param [Integer] discord_uid
    # @param [Integer] limit
    # @param [Symbol] datatype
    # @return [Boolean]
    def user_limit_reached?(discord_uid, limit, datatype)
      user_id = TohsakaBot.get_user_id(discord_uid.to_i).to_i
      query_result = TohsakaBot.db[datatype]
      query_result.where(:user_id => user_id).count >= limit.to_i
    end
  end

  module TriggerPersistence
    def trigger_data
      @trigger_data ||= TriggerData.new
    end
  end

  TohsakaBot.extend DatabaseAccess, TriggerPersistence
end
