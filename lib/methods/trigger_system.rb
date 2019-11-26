module TohsakaBot
  class TriggerSystem

    # attr_reader :trigger_words, :triggers_all

    def initialize
      @trigger_db = "#{CFG.bot.data}/triggers.yml"
      @full_size_triggers = YAML.load_file(@trigger_db)
      @only_trigger_words = []

      # Convert all regex found in the database to a form that Ruby can read,
      # and pass them in to a array which contains only the words that trigger reacts to.
      @full_size_triggers.each do |k, v|
        @only_trigger_words << v["trigger"].to_regexp(detect: true)
      end
    end

    #def reload_triggers
    #  @only_trigger_words = []
    #  @full_size_triggers.each do |key, value|
    #    @only_trigger_words << value["trigger"].to_regexp(detect: true)
    #  end
    #end

    def add_new_trigger(trigger_word, userid, chance, response: '', file_name: '' )

      trigger_db = YAML::Store.new(@trigger_db)

      trigger_db.transaction do
        i = 1
        while trigger_db.root?(i) do i += 1 end
        trigger_db[i] = {:trigger => trigger_word.to_s, :reply => response, :file => file_name, :user => userid.to_s, :chance => chance }
        trigger_db.commit
      end

      @only_trigger_words << trigger_word.to_regexp(detect: true)
      @full_size_triggers = YAML.load_file(@trigger_db)
    end

    def download_response_picture(file, userid, mod_trg_word)
      if /https:\/\/cdn.discordapp.com.*/.match?(file.url)

        o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
        string = (0...8).map { o[rand(o.length)] }.join
        file_name = file_name.gsub(File.extname(file_name), '') + "_" + string + File.extname(file_name)

        IO.copy_stream(open(file.url), "triggers/#{file_name}")
      end
    end
  end
end
