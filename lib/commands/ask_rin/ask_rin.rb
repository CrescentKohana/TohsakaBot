module TohsakaBot
  module Commands
    module AskRin
      extend Discordrb::Commands::CommandContainer
      command(:askrin,
              aliases: %i[ask rin],
              description: 'Ask Rin about something and she will deliver.',
              usage: 'askrin <question>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|

        msg = msg.join(' ').sanitize_string
        username = BOT.member(event.server, event.user.id).display_name.strip_mass_mentions.sanitize_string
        answer = ' '

        CSV.open("data/ask_rin_answers.csv", "r", :col_sep => "\t") do |csv|
          answer = csv.read.sample[0]
        end

        url = URI::regexp.match?(answer) ? true : false
        event.channel.send_embed do |embed|
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: answer) if url
          embed.colour = 0x36393F
          embed.add_field(name: "**#{username}**: ", value: "[#{msg}](https://discord.com/channels/" + "#{event.server.id}/#{event.channel.id}/#{event.message.id})")
          embed.add_field(name: "**Rin** (凛): ", value: "#{answer}") unless url
          embed.add_field(name: "**Rin** (凛): ", value: "🖼️") if url
        end
      end
    end
  end
end
