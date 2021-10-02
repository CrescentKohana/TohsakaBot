# frozen_string_literal: true

module TohsakaBot
  # Database access and methods which are utilizing it.
  module DatabaseAccess
    # Connection to the database.
    #
    # @return [void]
    def db(type: AUTH.db_type, sqlite: AUTH.sqlite_db)
      @db ||= case type.to_sym
              when :mysql
                Sequel.connect(
                  adapter: 'mysql2',
                  charset: 'utf8mb4',
                  collate: 'utf8mb4_unicode_ci',
                  host: AUTH.db_url,
                  database: AUTH.db_name,
                  user: AUTH.db_user,
                  password: AUTH.db_password
                )
              else
                Sequel.connect("sqlite://data/#{sqlite}")
              end
    end

    # Returns true if user is registered (present in the database), false if not.
    # If event is given and the user is not registered, sends a message which tells to register first.
    #
    # @param discord_uid [Integer]
    # @param event [EventContainer, nil]
    # @return [Boolean] is user registered?
    def registered?(discord_uid, event = nil)
      if TohsakaBot.get_user_id(discord_uid.to_i).to_i.positive?
        true
      else
        event&.respond I18n.t("errors.not_registered")
        false
      end
    rescue StandardError
      event&.respond I18n.t("errors.not_registered")
      false
    end

    # Returns bot's internal UID. Not the Discord User ID!
    #
    # @param discord_uid [Integer] Discord UID
    # @return [Integer, nil] internal ID for the user
    def get_user_id(discord_uid)
      user = TohsakaBot.db[:authorizations][uid: discord_uid.to_i]
      return user[:user_id].to_i unless user.nil?

      nil
    end

    # Returns Discord User ID.
    #
    # @param user_id [Integer] internal ID for the user
    # @return [Integer, nil] Discord UID
    def get_discord_id(user_id)
      user = TohsakaBot.db[:authorizations][user_id: user_id.to_i]
      return user[:uid].to_i unless user.nil?

      nil
    end

    # Returns user's locale.
    #
    # @param discord_uid [Integer] Discord User ID
    # @param symbol [Boolean] As symbol? (default: true)
    # @return [String, Symbol] locale (default: "en")
    def get_locale(discord_uid, symbol: true)
      user = TohsakaBot.db[:users][id: get_user_id(discord_uid)]
      locale = if user.nil? || user[:locale].blank? || !%w[en ja fi].include?(user[:locale])
                 "en"
               else
                 user[:locale]
               end

      return locale unless symbol

      locale.to_sym
    end

    # Checks if the user limit is reached for this datatype.
    # For example, if the user has 50 reminders, and the limit is 50, the method returns true.
    #
    # @param discord_uid [Integer]
    # @param limit [Integer] per user limit
    # @param datatype [Symbol] limit for what (:triggers, :reminders)
    # @return [Boolean] is user limit reached?
    def user_limit_reached?(discord_uid, limit, datatype)
      user_id = TohsakaBot.get_user_id(discord_uid.to_i).to_i
      query_result = TohsakaBot.db[datatype]
      query_result.where(user_id: user_id).count >= limit.to_i
    end
  end

  # Access to active triggers globally.
  # @example Access trigger phrases.
  #   TohsakaBot.trigger_data.trigger_phrases
  #
  # @return [TriggerData] triggers
  module PersistentTriggerData
    def trigger_data
      @trigger_data ||= TriggerData.new
    end
  end

  # Access to permissions and roles globally.
  #
  # @return [Hash] messages
  module PersistentPermissionsData
    def permissions
      @permissions ||= Permissions.new
    end
  end

  # Staggered message cache for sending messages in batches.
  #
  # @return [Hash] messages and embeds
  module PersistentMsgQueueCache
    def queue_cache
      @queue_cache ||= MsgQueueCache.new
    end
  end

  # Poll cache.
  #
  # @return [Hash] polls with votes
  module PersistentPollCache
    def poll_cache
      @poll_cache ||= PollCache.new
    end
  end

  # Rock Paper Scissors cache.
  #
  # @return [Hash] RPS games
  module PersistentRPSCache
    def rps_cache
      @rps_cache ||= RPSCache.new
    end
  end

  # Role cache.
  #
  # @return [Hash] polls with votes
  module PersistentRoleCache
    def role_cache
      @role_cache ||= TohsakaBot.read_server_roles
    end
  end

  TohsakaBot.extend(
    DatabaseAccess,
    PersistentTriggerData,
    PersistentPermissionsData,
    PersistentMsgQueueCache,
    PersistentPollCache,
    PersistentRPSCache,
    PersistentRoleCache
  )
end
