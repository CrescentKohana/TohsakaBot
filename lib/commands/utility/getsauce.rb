module TohsakaBot
  module Commands
    module GetSauce
      extend Discordrb::Commands::CommandContainer
      extend Discordrb::EventContainer
      command(:getsauce,
              aliases: %i[saucenao sauce rimg],
              description: 'Finds source for the posted image.',
              usage: 'sauce <link (or attachment)>') do |event, messageurl|

        if !event.message.attachments.first.nil?
          @aurl = event.message.attachments.first.url
          response = JSON.parse(open("https://saucenao.com/search.php?output_type=2&dbmask=32&api_key=#{AUTH.saucenao_apikey}&url=#{@aurl}").read)
          output = response['results'][0]['data']['pixiv_id']
        elsif messageurl
          if TohsakaBot.url_regex.match?(messageurl)
            apijson = open("http://saucenao.com/search.php?output_type=2&dbmask=32&minsim=60&api_key=#{AUTH.saucenao_apikey}&url=#{messageurl}")
            response = JSON.parse(apijson.read)
            output = response['results'][0]['data']['pixiv_id']
          else
            event.respond('URL was incorrect.')
            break
          end
        else
          event.respond('Upload an image with the command `sauce` or just with an URL `sauce https://website.com/image.png`')
          break
        end

        if !output.nil?
          # event.respond "The most accurate result: https://pixiv.moe/illust/#{output} 
          # \nMore results here: https://saucenao.com/search.php?output_type=0&dbmask=32&url=#{messageurl}"
          event.channel.send_embed do |embed|
            embed.title = 'Results:'
            embed.colour = 0xA82727
            embed.url = ''
            embed.description = 'Something.'
            embed.timestamp = Time.now

            embed.image = Discordrb::Webhooks::EmbedImage.new(url: messageurl || @aurl)
            # embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "")
            # embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Rin", icon_url: "")
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '', icon_url: '')

            embed.add_field(name: '**Pixiv.moe**', value: "https://pixiv.moe/illust/#{output}")
            embed.add_field(name: '**Pixiv**', value: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{output}")
            embed.add_field(name: '**Website X**', value: 'URL')
            embed.add_field(name: '**More results**', value: "[here](https://saucenao.com/search.php?output_type=0&dbmask=32&url=#{messageurl})")
          end
        else
          event.respond('Upload an image with the command `sauce` or just with an URL `sauce https://website.com/image.png`')
        end
      end
    end
  end
end
