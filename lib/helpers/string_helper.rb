class String
  # The zero-width space in between the @ and the word
  # prevents the tagging of everyone (or everyone online).
  def strip_mass_mentions
    gsub(/@here|@everyone/,
         '@here' => '@' + "\u200B" + 'here',
         '@everyone' => '@' + "\u200B" + 'everyone')
  end

  # Prevents escaping strings in bot commands
  # and such with '`' (code tag) characters by replacing them with '´'.
  # Idea by roni.
  def sanitize_string # legendary_sanitize_string
    tr('`', '´')
  end

  # Hides the preview in links posted by the bot by adding <link>.
  def hide_link_preview
    # TODO: Add a check if the link already has <> around it
    gsub(TohsakaBot.url_regex, '<\k<foo>>')
  end
end
