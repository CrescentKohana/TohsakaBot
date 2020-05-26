module TohsakaBot
  class TriggerController

    def initialize(event, msg)
      @event = event
      @phrase = msg.join(' ')
      @serverid = event.server.id.to_i
      @discord_uid = event.message.user.id.to_i
      @mode = 0
      @chance = 0

      if @phrase.include?("--any")
        @phrase = @phrase.match(/(.*)--any.*/)[1]
        @mode = 1
      end

      # Remove an unnecessary spaces
      @phrase.strip!
    end

    def store_trigger(response: "", filename: "")
      return unless TohsakaBot.registered?(@discord_uid)

      triggers = TohsakaBot.db[:triggers]
      TohsakaBot.db.transaction do
        @id = triggers.insert(phrase: @phrase,
                              reply: response,
                              file: filename,
                              user_id: TohsakaBot.get_user_id(@discord_uid),
                              server_id: @serverid,
                              chance: @chance,
                              mode: @mode,
                              created_at: Time.now,
                              updated_at: Time.now)
      end

      TohsakaBot.trigger_data.reload_active

      # Return the id to the user.
      @id
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

