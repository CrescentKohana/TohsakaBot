module TohsakaBot
  # Handling of trigger data.
  class TriggerData
    attr_accessor :triggers, :trigger_phrases
    @triggers
    @trigger_phrases


    # Loads active triggers to the memory.
    #
    # @return [void]
    def initialize
      reload_active
    end

    # Convert all strings queried from the database to regex,
    # and pass them in to an array which only contains triggerable phrases.
    #
    # @return [void]
    def reload_active(reload_events = false)
      @triggers = TohsakaBot.db[:triggers]
      @trigger_phrases = @triggers.select(:phrase).select{:phrase}.map{ |p| p.values }.flatten.map { |p|
        regex = p.to_regexp
        if regex.nil?
          "/#{p}/".to_regexp
        else
          p.to_regexp
        end }

      #if reload_events
      #TohsakaBot::BOT.clear!
        #load "#{File.dirname(__FILE__)}/../events/trigger_event.rb"
        #BOT.include!(TohsakaBot.const_get("Events::TriggerEvent"))
        #TohsakaBot.load_modules(:Events, 'events/*/*', true, true)

      #modules = JSON.parse(File.read('data/persistent/bot_state.json')).transform_keys(&:to_sym)
      # Dir["#{File.dirname(__FILE__)}/../events/*/*.rb"].each { |file| load file }

      #modules[:Events].each do |k|
      #  symbol_to_class = TohsakaBot.const_get("Events::#{k}")
      #   BOT.include!(symbol_to_class)
      #  end
      #end
    end

    # Moves all trigger files not found in the database to tmp/deleted_triggers.
    #
    # @return [void]
    def clean_trigger_files
      puts "Cleaning trigger files.."
      triggers_files = TohsakaBot.db[:triggers].select(:phrase).select{:file}.map{ |p| p.values}.flatten
      Dir.foreach('data/triggers/') do |filename|
        next if filename == '.' or filename == '..' or filename == '.keep'
        next if triggers_files.include? filename
        FileUtils.mv("data/triggers/#{filename}", "tmp/deleted_triggers/#{filename}")
      end
      puts "Done cleaning trigger files."
    end
  end
end
