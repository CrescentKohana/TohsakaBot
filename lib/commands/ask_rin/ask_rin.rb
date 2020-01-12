module TohsakaBot
  module Commands
    module AskRin
      extend Discordrb::Commands::CommandContainer
      command(:askrin,
              aliases: %i[ask rin],
              description: 'Ask Rin about something and she will deliver.',
              min_args: 1,
              usage: 'askrin <question>',
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|

        msg = msg.join(' ').sanitize_string
        username = BOT.member(event.server, event.user.id).display_name.strip_mass_mentions.sanitize_string
        answer = ' '

        CSV.open("data/ask_rin_answers.csv", "r", :col_sep => "\t") do |csv|
          answer = csv.read.sample[0]
        end

        event.channel.send_embed do |embed|
          # embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://cdn.discordapp.com/attachments/351170098754486289/648936891890008120/22_1615-a1fef0.png")
          embed.colour = 0x36393F
          embed.title = ""
          embed.url = ""
          embed.description = ""
          embed.add_field(name: "**#{username}**: ", value: "[#{msg}](https://discordapp.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})")
          embed.add_field(name: "**Rin** (凛): ", value: "#{answer}")
          # embed.timestamp = Time.now
          # embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "", icon_url: "")
        end
      end
    end
  end
end
