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
            # embed.url = ""
            embed.add_field(name: "**WANHA**", value: "[#{user_obj.username}](https://discord.com/channels/#{msg_uri})")
            embed.timestamp = time
          end
        end
      end
    end
  end
end
