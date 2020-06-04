module TohsakaBot
  class TriggerData
    attr_accessor :active_triggers
    # @full_triggers
    @active_triggers
    @triggers

    def initialize
      @triggers = TohsakaBot.db[:triggers]
      @active_triggers = @triggers.select(:phrase).select{:phrase}.map{ |p| p.values}.flatten

      # Convert all regex found in the database to a suitable form for Ruby,
      # and pass them in to an array which only contains triggerable phareses.
      #@full_triggers.each do |k, v|
      #  if v["mode"].to_i == 0 || v["mode"].to_i == 1
      #    # @active_triggers << /#{v["phrase"]}/i
      #    @active_triggers << /.*\b#{v["phrase"]}\b.*/
      #  else
      #    @active_triggers << v["phrase"].to_regexp(detect: true)
      #  end
      #end
    end

    def reload_active
      @triggers = TohsakaBot.db[:triggers]
      @active_triggers = @triggers.select(:phrase).select{:phrase}.map{ |p| p.values}.flatten
    end

    # Moves any trigger file not in the database to tmp/deleted_triggers.
    def clean_trigger_files
      puts "Cleaning trigger files.."
      triggers_files = TohsakaBot.db[:triggers].select(:phrase).select{:file}.map{ |p| p.values}.flatten
      Dir.foreach('data/triggers/') do |filename|
        next if filename == '.' or filename == '..'
        next if triggers_files.include? filename
        FileUtils.mv("data/triggers/#{filename}", "tmp/deleted_triggers/#{filename}")
      end
      puts "Done cleaning trigger files."
    end
  end
end
