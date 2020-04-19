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

  module TriggerPersistence
    def trigger_data
      @trigger_data ||= TriggerData.new("data/triggers.yml")
    end
  end

  TohsakaBot.extend TriggerPersistence
end
