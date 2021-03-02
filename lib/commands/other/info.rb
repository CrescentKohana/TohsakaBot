module TohsakaBot
  module Commands
    module Information
      extend Discordrb::Commands::CommandContainer
      command(:info,
              aliases: %i[information],
              description: 'Basic information about the bot.',
              usage: '') do |event|

        event.channel.send_embed do |embed|
          embed.title = 'INFO'
          embed.colour = 0xA82727
          embed.url = ''
          embed.description = ''
          embed.timestamp = Time.now

          embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://cdn.discordapp.com/attachments/351170098754486289/648936828212215812/22_1602-4fe170.gif')
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'Rin', icon_url: 'https://cdn.discordapp.com/attachments/351170098754486289/648936891890008120/22_1615-a1fef0.png')
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Made with Ruby', icon_url: 'https://cdn.discordapp.com/emojis/232899886419410945.png')

          embed.add_field(name: 'Created by', value: 'Luukuton#3717')
          embed.add_field(name: 'Source code', value: '[GitHub](https://github.com/Luukuton/TohsakaBot)')
        end
      end
    end
  end
end
