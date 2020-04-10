module TohsakaBot
  class TriggerData
    attr_accessor :active_triggers, :full_triggers, :db_path
    Trigger = Struct.new(:phrase, :reply, :file, :user, :chance, :mode)

    @db_path
    @full_triggers
    @active_triggers

    def initialize(db_path)
      @db_path = db_path
      @full_triggers = YAML.load_file(db_path)
      @active_triggers = []

      # Convert all regex found in the database to a suitable form for Ruby,
      # and pass them in to an array which only contains triggerable phareses.
      @full_triggers.each do |k, v|
        if v["mode"].to_i == 0
          @active_triggers << /#{v["phrase"]}/i
        elsif v["mode"].to_i == 1
          @active_triggers << /.*\b#{v["phrase"]}\b.*/i
        else
          @active_triggers << v["phrase"].to_regexp(detect: true)
        end
      end
    end
  end
end
