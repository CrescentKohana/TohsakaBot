module TohsakaBot
  # Controller class class for managing triggers.
  #
  class TriggerController
    # Stores the trigger to the database and reloads active triggers in bot's memory.
    #
    # @param event [EventContainer] EventContainer for Message event
    # @param phrase [String] phrase to which the bot responses (triggers)
    # @param mode [Integer] trigger mode [exact (0), any (2), regex(3)]
    def initialize(event, phrase, mode)
      @event = event
      @phrase = phrase
      @server_id = event.server.id.to_i
      @discord_uid = event.message.user.id.to_i
      @chance = 0
      @mode = /e.*/s.match?(mode) ? 0 : 1

      # Remove an unnecessary spaces
      @phrase.strip!
    end

    # Stores the trigger to the database and reloads active triggers in bot's memory.
    #
    # @param reply [String] reply to the trigger
    # @param filename [String] filename of the reply file to the trigger
    # @return [Integer] ID of the trigger in the database
    def store_trigger(reply: "", filename: "")
      return unless TohsakaBot.registered?(@discord_uid)

      triggers = TohsakaBot.db[:triggers]
      TohsakaBot.db.transaction do
        @id = triggers.insert(phrase: @phrase,
                              reply: reply,
                              file: filename,
                              user_id: TohsakaBot.get_user_id(@discord_uid),
                              server_id: @server_id,
                              chance: @chance,
                              mode: @mode,
                              created_at: Time.now,
                              updated_at: Time.now)
      end

      TohsakaBot.trigger_data.reload_active
      # Return the created id to the user.
      @id
    end

    # Downloads the file associated with the trigger. Returns nil if filesize more than Discord's bot limit.
    #
    # @param reply [EventContainer] EventContainer for Message event
    # @return [String, nil] final filename with UUID
    def download_reply_picture(reply)
      file = reply.message.attachments.first
      if /https:\/\/cdn.discordapp.com.*/.match?(file.url)

        # Add an unique ID at the end of the filename.
        o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
        string = (0...8).map { o[rand(o.length)] }.join
        filename = file.filename
        final_filename = filename.gsub(File.extname(filename), '') + '_' + string + File.extname(filename)

        IO.copy_stream(URI.open(file.url), "data/triggers/#{final_filename}")

        return nil if File.size("data/triggers/#{final_filename}") > TohsakaBot::DiscordHelper::UPLOAD_LIMIT

        final_filename
      end
    end
  end
end

