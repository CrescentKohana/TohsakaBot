module TohsakaBot
  module Events
    module Repost
      extend Discordrb::EventContainer
      message(content: $url_regexp) do |event|
        url = URI.extract(event.message.content)
        db = YAML.load_file('data/repost.yml')

        db.each do |key, value|
          if url[0] == value["url"] && event.author.id.to_i != value["user"].to_i
            t = Time.at(value["time"].to_i)
            user_obj = BOT.member(event.server, value["user"])
            event.channel.send_file(File.open("img/repostimiespate.jpg"))

            # event.respond "WANHA `by #{user_obj.display_name} @ #{t} (X)`"

            event.channel.send_embed do |embed|
              embed.colour = 0x36393F
              embed.title = ""
              embed.url = ""
              embed.description = ""
              embed.add_field(name: "🎲 **#{result.to_s.rjust(padding, '0')}**", value: "[#{username}](https://discordapp.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})")
              # embed.timestamp = Time.now
              # embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "", icon_url: "")
            end
            break
          end
        end
      end
    end
  end
end