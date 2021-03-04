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
    def reload_active
      @triggers = TohsakaBot.db[:triggers]
      @trigger_phrases = @triggers.select(:phrase).select{:phrase}.map(&:values).flatten.map { |p|
        regex = p.to_regexp
        if regex.nil?
          "/#{p}/".to_regexp
        else
          p.to_regexp
        end
      }
    end

    # Returns the correct chance for depending on the trigger mode.
    #
    # @return [Integer] chance as percentage
    def parse_chance(chance, mode)
      chance = chance.to_i
      chance = chance.zero? ? CFG.default_trigger_chance.to_i : chance
      chance = case mode
               when 2
                 chance
               when 1
                 chance * 3
               else
                 chance
               end

      return 100 if chance > 100

      chance
    end

    # Moves all trigger files not found in the database to tmp/deleted_triggers.
    #
    # @return [void]
    def clean_trigger_files
      puts 'Cleaning trigger files..'
      triggers_files = TohsakaBot.db[:triggers].select(:phrase).select{:file}.map(&:values).flatten
      Dir.foreach('data/triggers/') do |filename|
        next if %w[. .. .keep].include?(filename)
        next if triggers_files.include? filename

        FileUtils.mv("data/triggers/#{filename}", "tmp/deleted_triggers/#{filename}")
      end
      puts 'Done cleaning trigger files.'
    end
  end
end
