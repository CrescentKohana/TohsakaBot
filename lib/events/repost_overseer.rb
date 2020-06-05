module TohsakaBot
  module Events
    module RepostOverseer
      extend Discordrb::EventContainer
      message(content: TohsakaBot.url_regex) do |event|
        time, discord_uid, msg_uri = TohsakaBot.url_match(event)

        unless time.nil?
          time = Time.at(time)
          user_obj = BOT.member(event.server, discord_uid)

          event.channel.send_embed do |embed|
            embed.colour = 0x36393F
            #embed.title = "WANHA"
            # embed.url = ""
            # embed.description = ""
            # embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "", icon_url: "")
            embed.add_field(name: "**WANHA**", value: "[#{user_obj.username}](https://discordapp.com/channels/#{msg_uri})")
            embed.timestamp = time
          end
        end

        # event.respond "WANHA `by #{user_obj.display_name} @ #{t} (X)`"
      end
    end
  end
end
