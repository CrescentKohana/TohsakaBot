module TohsakaBot
  class TriggerCore
    def initialize(event, msg)
      @event = event
      @phrase = msg.join(' ')
      @userid = event.message.user.id
      @parameter, @chance = 0
      @trigger_db = "data/triggers.yml"
      # @full_triggers = YAML.load_file(@trigger_db)
      # @active_triggers = []

      if @phrase.include?("--any")
        @phrase.slice! "--any"
        @parameter = 1
      end

      if @phrase.include? "--reg"
        @phrase.slice! "--reg"
        @parameter = 2
      end

      # Remove an unnecessary spaces
      @phrase[0] = "" if @phrase[0] == " "
      @phrase[-1] = "" if @phrase[-1] == " "

      # Convert all regex found in the database to a form suitable for Ruby,
      # and pass them in to an array which only contains phareses which can be triggered.
      # @full_triggers.each do |k, v|
      #   @active_triggers << v["phrase"].to_regexp(detect: true)
      # end
    end

    def add_new_trigger(response: '', filename: '')
      trigger_db = YAML::Store.new(@trigger_db)
      i = 1
      trigger_db.transaction do
        i += 1 while trigger_db.root?(i)
        trigger_db[i] = {
            "phrase"  => @phrase.to_s,
            "reply"   => response,
            "file"    => filename,
            "user"    => @userid.to_s,
            "chance"  => @chance,
            "mode"    => @parameter
        }
        trigger_db.commit
      end

      # @active_triggers << @phrase.to_regexp(detect: true)
      # @full_triggers = YAML.load_file(@trigger_db)
      $triggers_only << @phrase.to_regexp(detect: true)
      $triggers = YAML.load_file(@trigger_db)
      i
    end

    def download_response_picture
      file = @event.message.attachments.first
      if /https:\/\/cdn.discordapp.com.*/.match?(file.url)
        # Add an unique ID at the end of the filename.
        o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
        string = (0...8).map { o[rand(o.length)] }.join
        filename = file.filename
        full_filename = filename.gsub(File.extname(filename), '') + "_" + string + File.extname(filename)
        IO.copy_stream(open(file.url), "triggers/#{full_filename}")
        full_filename
      end
    end
  end
end
