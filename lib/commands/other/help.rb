module TohsakaBot
  module Commands
    module Help
      extend Discordrb::Commands::CommandContainer
      command(:help,
              aliases: %i[sendhelp],
              description: 'Help me.',
              usage: '',
              rescue: "Something went wrong!\n`%exception%`") do |event, where|

        @sendhelp = if where.to_s == "here"
                      event.channel
                    else
                      event.author.pm
                    end

        @sendhelp.send_embed do |embed|
          embed.title = "**COMMANDS & OTHER STUFF**"
          embed.colour = 0xA82727
          embed.url = ""
          embed.description = "_The prefix for all commands is #{$settings['prefix']}_"
          embed.timestamp = Time.now

          embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://cdn.discordapp.com/attachments/351170098754486289/648936828212215812/22_1602-4fe170.gif")
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Rin", icon_url: "https://cdn.discordapp.com/attachments/351170098754486289/648936891890008120/22_1615-a1fef0.png")
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Made with Ruby", icon_url: "https://cdn.discordapp.com/emojis/232899886419410945.png")

          embed.add_field(name: ":white_small_square: ping", value: "pong.")
          embed.add_field(name: ":white_small_square: chaos <msg>", value: "cHaOs")
          embed.add_field(name: ":white_small_square: stars <user> <message>", value: "きらきら")
          embed.add_field(name: ":white_small_square: encode <channel (id, name or nothing for DM)> <message>", value: "Channels: main, pelit, mökki, opiskelu & anime. Encodes the message with ROT13 and sends it either to the specified channel or to you (ROT13).")
          # Depreceated because of the native spoiler feature in Discord.
          # embed.add_field(name: ":white_small_square: spoiler <for what> <message (1016 characters max)>", value: "Adds a reaction to the message with which you can decode it (ROT13).")
          embed.add_field(name: ":white_small_square: coinflip", value: "Flips a coin. Three different outcomes and multiple aliases for the command.")
          embed.add_field(name: ":white_small_square: addrole || delrole <role>", value: "Add a role to yourself or remove it.")
          embed.add_field(name: ":white_small_square: remindme <R〇y〇M〇w〇d〇h〇m〇s | time as natural language | ISO8601 etc.. (if spaces, use ; after the time)> <msg> (R for repeated, >10 minutes)", value: "You can use this to remind yourself when it's time to stop.")
          embed.add_field(name: ":white_small_square: reminders", value: "Check all of your active reminders.")
          embed.add_field(name: ":white_small_square: delreminder <ids separeted by space (integer)>", value: "Deletes an active reminder.")
          embed.add_field(name: ":white_small_square: alko <max price in euros (integer)> <type>", value: "Searches alko.fi for something to drink within your budget.")
          embed.add_field(name: ":white_small_square: alkolist", value: "Shows all usable types with the ?alko command.")
          embed.add_field(name: ":white_small_square: addtrigger <regex: y/n> <trigger word>", value: "Adds a trigger to the bot which actives with the specified word (base chance #{$settings['default_trigger_chance']}%).")
          embed.add_field(name: ":white_small_square: triggers", value: "Checks all of your current triggers.")
          embed.add_field(name: ":white_small_square: deltrigger <ids separeted by space (integer)>", value: "Deletes one trigger.")
          embed.add_field(name: ":white_small_square: summon <servant>", value: "WIP. Servants currently usable: saber, archer, lancer.")
          embed.add_field(name: ":black_small_square: **Event triggers**", value: "They consist of ayyy, banaanikissa and a lot more.")
          #embed.add_field(name: "<:thonkang:219069250692841473>", value: "are inline fields", inline: true)
        end
      end
    end
  end
end
