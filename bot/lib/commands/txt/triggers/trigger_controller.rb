# frozen_string_literal: true

module TohsakaBot
  # Controller class class for managing triggers.
  class TriggerController
    # Stores the trigger to the database and reloads active triggers in bot's memory.
    #
    # @param event [EventContainer] EventContainer for Message event
    # @param phrase [String] phrase to which the bot responses (triggers)
    # @param mode [Integer] trigger mode [exact (0), any (1), regex (2)]
    # @return [void]
    def initialize(event, phrase, mode)
      @event = event
      @phrase = phrase
      @server_id = event.server.id.to_i
      @discord_uid = event.message.user.id.to_i
      @mode = mode.nil? ? 1 : mode
      @chance = 0

      # Remove an unnecessary spaces
      @phrase.strip!
    end

    # Stores the trigger to the database and reloads active triggers in bot's memory.
    #
    # @param reply [String] reply to the trigger
    # @param filename [String] filename of the reply file to the trigger
    # @return [String] Message to the user
    def store_trigger(reply: '', filename: '')
      return unless TohsakaBot.registered?(@discord_uid)

      if @mode.zero? && TohsakaBot.db[:triggers].where(phrase: @phrase, mode: 0).select.first
        return "Exact trigger with the phrase `#{@phrase}` already exists! Choose another phrase or use 'any' mode."
      end

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
      "Trigger added `<ID #{@id}>`."
    end

    # Updates the trigger in the database and reloads active triggers in bot's memory.
    #
    # @param trigger Database object
    # @return [String] Message to the user
    def self.update_trigger(trigger)
      triggers = TohsakaBot.db[:triggers]

      if trigger[:mode].zero? && triggers.where(phrase: trigger[:phrase], mode: 0).exclude(id: trigger[:id]).select.first
        raise ExactTriggerAlreadyExists.new(phrase: trigger[:phrase])
      end

      TohsakaBot.db.transaction do
        triggers.where(id: trigger[:id].to_i).update(trigger)
      end

      TohsakaBot.trigger_data.reload_active
      "Trigger modified `<ID #{trigger[:id]}>`."
    end

    # Downloads the file associated with the trigger. Returns nil if filesize more than Discord's bot limit.
    #
    # @param reply [EventContainer] EventContainer for Message event
    # @return [String, nil] final filename with UUID
    def self.download_reply_picture(reply)
      file = reply.message.attachments.first
      return unless %r{https://cdn.discordapp.com.*}.match?(file.url)

      final_filename = file.filename.gsub(File.extname(file.filename), '').to_s.add_identifier
      final_filename += File.extname(file.filename)

      IO.copy_stream(URI.open(file.url), CFG.data_dir + "/triggers/#{final_filename}")

      return nil if File.size(CFG.data_dir + "/triggers/#{final_filename}") > TohsakaBot.server_upload_limit(reply.server.id)

      final_filename
    end

    # Determines which mode to set.
    #
    # @param mode_input [String]
    # @return [Integer, nil] 0, 1 or 2 as the mode identifier. nil if no permissions.
    def self.select_mode(mode_input, discord_uid)
      case mode_input
      when /e.*/si
        0
      when /r.*/si
        return nil unless TohsakaBot.permissions.able?(discord_uid, "regex_triggers", :perm)

        2
      else
        1
      end
    end
  end
end
