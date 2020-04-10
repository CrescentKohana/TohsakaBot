module TohsakaBot
  class TriggerSession

    def initialize(event, msg)
      @event = event
      @phrase = msg.join(' ')
      @userid = event.message.user.id.to_i
      @parameter, @chance = 0

      if @phrase.include?("--any")
        @phrase.match(/(.*)--any.*/)[1]
        @parameter = 1
      end

      # Remove an unnecessary spaces
      @phrase.strip!
    end

    def add_new_trigger(response: "", filename: "")
      trigger_db = YAML::Store.new(TohsakaBot.trigger_data.db_path)
      new_trigger = TriggerData::Trigger.new(@phrase, response, filename, @userid, @chance.to_i, @parameter.to_i)
      i = 1

      trigger_db.transaction do
        i += 1 while trigger_db.root?(i)
        trigger_db[i] = new_trigger
        trigger_db.commit
      end

      if @parameter == 0
        TohsakaBot.trigger_data.active_triggers << /#{@phrase}/i
      else
        TohsakaBot.trigger_data.active_triggers << /.*\b#{@phrase}\b.*/i
      end

      TohsakaBot.trigger_data.full_triggers = YAML.load_file(TohsakaBot.trigger_data.db_path)

      # Return the id to the user.
      i
    end

    def download_response_picture(response)
      file = response.message.attachments.first
      if /https:\/\/cdn.discordapp.com.*/.match?(file.url)

        # Add an unique ID at the end of the filename.
        o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
        string = (0...8).map { o[rand(o.length)] }.join
        filename = file.filename
        full_filename = filename.gsub(File.extname(filename), '') + '_' + string + File.extname(filename)

        IO.copy_stream(URI.open(file.url), "triggers/#{full_filename}")
        full_filename
      end
    end
  end
end

