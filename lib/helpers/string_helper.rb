# frozen_string_literal: true

class String
  # The zero-width space in between the @ and the word
  # prevents the tagging of everyone (or everyone online).
  #
  # @return [String] message with disabled mass mentions
  def strip_mass_mentions
    gsub(/@here|@everyone/,
         '@here' => "@​here",
         '@everyone' => "@​everyone")
  end

  # Prevents escaping strings in bot commands
  # and such with '`' (code tag) characters by escaping them
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
    gsub(TohsakaBot.url_regex(capture_group: true), '<\k<capture>>')
  end

  def first_number
    self[/\b\d+\b/]
  end

  # Adds a random identifier at the end of the string
  def add_identifier
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    id = (0...8).map { o[rand(o.length)] }.join
    concat("_#{id}")
  end
end
