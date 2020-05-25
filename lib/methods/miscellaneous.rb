module TohsakaBot
  def self.load_modules(klass, path, discord = true, clear = false)
    modules = JSON.parse(File.read('cfg/bot_state.json')).transform_keys(&:to_sym)

    if clear
      BOT.clear!
      if klass == :Async
        modules[klass].each do |k|
          Thread.kill(k.to_s.downcase)
        end
      end
    end

    Dir["#{File.dirname(__FILE__)}/../#{path}.rb"].each { |file| load file }

    if discord
      modules[klass].each do |k|
        symbol_to_class = TohsakaBot.const_get("#{klass}::#{k}")
        TohsakaBot::BOT.include!(symbol_to_class)
      end
    end
  end

  def self.expire_msg(bot_msgs, user_msg: nil, duration: 60)
    sleep(duration)
    user_msg.delete unless user_msg.nil?
    bot_msgs.each {|m| m.delete}
    return
  end

  def self.send_multiple_msgs(content, where)
    msg_objects = []
    content.each { |c| msg_objects << where.send_message(c) }
    msg_objects
  end

  # Checks if the user limit is reached for this datatype.
  # For example, if the user has 50 reminders, and the limit is 50, the method returns true.
  #
  # @param [Integer] discord_uid
  # @param [Integer] limit
  # @param [Symbol] datatype
  # @return [Boolean]
  def self.user_limit_reached?(discord_uid, limit, datatype)
    user_id = TohsakaBot.get_user_id(discord_uid.to_i).to_i
    query_result = TohsakaBot.db[datatype]
    query_result.where(:user_id => user_id).count >= limit.to_i
  end
end
