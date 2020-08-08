module TohsakaBot
  class TriggerController
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
      # Return the id to the user.
      @id
    end

    def download_reply_picture(reply)
      file = reply.message.attachments.first
      if /https:\/\/cdn.discordapp.com.*/.match?(file.url)

        # Add an unique ID at the end of the filename.
        o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
        string = (0...8).map { o[rand(o.length)] }.join
        filename = file.filename
        full_filename = filename.gsub(File.extname(filename), '') + '_' + string + File.extname(filename)

        IO.copy_stream(URI.open(file.url), "data/triggers/#{full_filename}")

        return nil if File.size("data/triggers/#{full_filename}") > TohsakaBot::DiscordHelper::UPLOAD_LIMIT

        full_filename
      end
    end
  end
end

