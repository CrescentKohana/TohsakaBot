# Methods accessible everywhere.
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
    url_regex = %r{(?<foo>(?:(?:https?|ftp):\/\/)
                   (?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})
                   (?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})
                   (?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])
                   (?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
                   (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
                   (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|
                   (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)
                   (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*
                   (?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?)}ix
    # TODO: Add a check if the link already has <> around it
    gsub(url_regex, '<\k<foo>>')
  end
end
