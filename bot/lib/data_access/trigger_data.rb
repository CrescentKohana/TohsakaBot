# frozen_string_literal: true

module TohsakaBot
  # Handling of trigger data.
  class TriggerData
    attr_accessor :triggers, :trigger_phrases

    SORT = %i[descending ascending].freeze
    APPEARANCE_TYPES = %i[calls occurrences].freeze

    # Loads active triggers to the memory.
    #
    # @return [void]
    def initialize
      reload_active
    end

    # Converts all strings queried from the database to regex,
    # and passes them in to an array containing only triggerable phrases.
    #
    # @return [void]
    def reload_active
      @triggers = TohsakaBot.db[:triggers]
      @trigger_phrases = @triggers.select(:phrase).select { :phrase }.map(&:values).flatten.map do |p|
        if p.match(%r{/.*/.*})
          Regexp.new p
        else
          Regexp.new "/#{p}/"
        end
      end
    end

    # Returns the correct chance for depending on the trigger mode.
    #
    # @return [Integer] chance as percentage
    def parse_chance(chance, mode)
      parsed_chance = chance.to_i.zero? ? CFG.default_trigger_chance.to_i : chance.to_i
      parsed_chance = mode.to_i.zero? ? parsed_chance * 3 : parsed_chance
      return 100 if parsed_chance > 100

      parsed_chance
    end

    # Returns an array of best triggers
    #
    # @return [Array]
    def statistics(sorting: :descending, mode: nil, proportional_chance: false, appearance_type: :occurrences)
      # Excluding triggers with 0 calls or occurrences with exclude.
      stats = if mode.nil?
                TohsakaBot.db[:triggers].exclude(appearance_type => 0)
              else
                TohsakaBot.db[:triggers].where(mode: mode).exclude(appearance_type => 0)
              end

      stats = if proportional_chance
                stats.sort_by do |trigger|
                  (trigger[appearance_type] * (100 / (trigger[:chance].zero? ? CFG.default_trigger_chance.to_i : trigger[:chance])))
                end
              else
                stats.sort_by { |trigger| trigger[appearance_type] }
              end

      stats.reverse! if sorting == :descending
      stats
    end

    # Moves all trigger files not found in the database to tmp/deleted_triggers.
    #
    # @return [void]
    def clean_trigger_files
      puts 'Cleaning files of deleted triggers..'
      triggers_files = TohsakaBot.db[:triggers].select(:phrase).select { :file }.map(&:values).flatten
      Dir.foreach(CFG.data_dir + '/triggers/') do |filename|
        next if %w[. .. .keep].include?(filename)
        next if triggers_files.include? filename

        FileUtils.mv(CFG.data_dir + "/triggers/#{filename}", "../tmp/deleted_triggers/#{filename}")
      end
      puts 'Done cleaning trigger files.'
    end
  end
end
