class String
  # The zero-width space in between the @ and the word
  # prevents the tagging of everyone (or everyone online).
  #
  # @return [String] message with disabled mass mentions
  def strip_mass_mentions
    gsub(/@here|@everyone/,
         '@here' => '@' + "\u200B" + 'here',
         '@everyone' => '@' + "\u200B" + 'everyone')
  end

  # Prevents escaping strings in bot commands
  # and such with '`' (code tag) characters by replacing them with '´'.
  # Idea by roni.
  #
  # @return [String] sanitized message
  def sanitize_string
    tr('`', '\`')
  end

  # Hides the preview in links posted by the bot by adding <> around the link.
  #
  # @return [String] message with modified links
  def hide_link_preview
    # TODO: Add a check if the link already has <> around it
    gsub(TohsakaBot.url_regex(true), '<\k<capture>>')
  end
end
