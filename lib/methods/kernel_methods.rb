# Methods accessible everywhere.
module Kernel

  # If the author of the event is a bot, skip the execution of code.
  def skip_if_bot?
     if user.current_bot? then return end
  end

  # The zero-width space in between the @ and the word
  # prevents the tagging of everyone (or everyone online).
  def strip_mass_mentions
    gsub(/@here|@everyone/,
         '@here' => '@' + "\u200B" + 'here',
         '@everyone' => '@' + "\u200B" + 'everyone')
  end

  def self.delete_yaml_key(file, key)
    rstore = YAML::Store.new(file.to_s)
    rstore.transaction do
      rstore.delete(key)
      rstore.commit
    end
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

  def user_limit_reached?(database, limit, userid)
    all = YAML.load_file(database)
    reminders_amount = 0

    all.each do |k, v|
      if userid == v["user"].to_i
        reminders_amount += 1
      end
    end
    reminders_amount > limit.to_i
  end

  def self.send_message_with_reaction(bot, cid, emoji, content)
    reply = bot.send_message(cid.to_i, content)
    reply.create_reaction(emoji)
  end

  # Sends an embedded message with the rolled number and
  # the name of the user who rolled combined
  # with a link to the original message.
  def self.send_embedded_roll(event, result, username, padding)
    event.channel.send_embed do |embed|
      embed.colour = 0x36393F
      embed.title = ""
      embed.url = ""
      embed.description = ""
      embed.add_field(name: "🎲 **#{result.to_s.rjust(padding, '0')}**", value: "[#{username}](https://discordapp.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})")
      # embed.timestamp = Time.now
      # embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "", icon_url: "")
    end
  end

  def self.delete_temporary_role_db(user_id, role_id)
    db_read = YAML.load_file('data/temporary_roles.yml')
    db_store = YAML::Store.new('data/temporary_roles.yml')

    db_read.each do |k, v|
      if role_id == v['role'].to_i && user_id == v['user'].to_i
        db_store.transaction do
          db_store.delete(k)
          db_store.commit
        end
      end
    end
  end

  def self.give_temporary_role(event, role_id, user_id)
    db_store = YAML::Store.new('data/temporary_roles.yml')
    server_id = event.channel.server.id

    # If the user already has an entry for the role, this deletes it first.
    delete_temporary_role_db(user_id, role_id)

    # Gives the role to the user unless they have it.
    unless TohsakaBot::BOT.member(event.server, user_id).role?(role_id)
      Discordrb::API::Server.add_member_role("Bot #{$config['bot_token']}", server_id, user_id, role_id)
    end

    # Makes a new entry to the database for the user so that we can delete the role after a set time (default: a week).
    db_store.transaction do
      i = 1
      i += 1 while db_store.root?(i)
      db_store[i] = { 'time' => Time.now, 'user' => user_id, 'server' => server_id, 'role' => role_id }
      db_store.commit
    end
  end

  # TODO: WIP
  def self.delete_previous_bot_msg(sent_msg)
    remove_msg = event.message.await!(timeout: 15)
    if remove_msg.content == $settings['msg_removal_word']
      sent_msg.delete
    end
  end
end
