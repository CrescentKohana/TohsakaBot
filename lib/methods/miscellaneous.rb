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

  # Source for the binomial coefficent "n choose k" below
  # https://creativecommons.org/licenses/by-sa/3.0/ "Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)"
  # https://www.programming-idioms.org/idiom/67/binomial-coefficient-n-choose-k/1656/ruby (2020/06/03)
  def self.ncr(n, k)
    (1 + n - k..n).inject(:*) / (1..k).inject(:*)
  end

  # n = total rolls, k = total hits, p = chance to hit
  # (n choose k) * (p^k) * ((1-p)^(n-k))
  def self.calc_probability(n, k, p)
    # Strange bug where ncr(n, k) * (p ** k) would sometimes give NaN instead of 0.0
    # is fixed by checking if a step is NaN and converting it into 0.0.
    # ncr(n, k) * (p ** k) * ((1 - p) ** (n - k))
    step = (ncr(n, k) * (p ** k))
    step = 0.0 if step.nan?
    step * (1 - p) ** (n - k)
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
