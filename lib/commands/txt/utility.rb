# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Utility
      extend Discordrb::Commands::CommandContainer

      command(:rollprobability,
              aliases: %i[rollchance chanceroll rollp rollc],
              description: 'Returns the probability of getting k hits within n amount of rolls with the chance of p.',
              usage: 'rollprobability <chance in % (float|int)> <rolls (int)> <hits (int, default: 1)>',
              min_args: 2) do |event, chance, rolls, hits|
        chance = chance.to_f / 100
        rolls = rolls.to_i
        hits = hits.to_i || 1

        unless (0..100).include?(chance) || (1..1000).include?(rolls) || (1..1000).include?(hits)
          event.<< 'Limits for the arguments are 0-100 (chance), 1-1000 (times), 1-1000 (correct).'
          break
        end

        if rolls < hits
          event.<< 'Total times has to be equal or more than correct times.'
          break
        end

        probability_one = TohsakaBot.calc_probability(rolls, hits, chance)
        probability_one_or_more = probability_one

        (hits + 1..rolls).each do |i|
          probability_one_or_more += TohsakaBot.calc_probability(rolls, i, chance)
        end

        reply = "The probability of #{hits} or more being correct within #{rolls} rolls"\
                " with the chance of #{chance * 100}% is approximately #{probability_one_or_more * 100}%."
        event.respond reply
      end

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
            embed.add_field(name: '**Pixiv**',
                            value: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{output}")
            embed.add_field(name: '**Website X**', value: 'URL')
            embed.add_field(name: '**More results**',
                            value: "[here](https://saucenao.com/search.php?output_type=0&dbmask=32&url=#{messageurl})")
          end
        else
          event.respond('Upload an image with the command `sauce` or just with an URL `sauce https://website.com/image.png`')
        end
      end

      command(:quickie,
              aliases: %i[snapchat sc qm],
              description: 'A quick message which is deleted after n seconds.',
              usage: 'quickie <1-10 (seconds, integer, default 5)> <message>') do |event, s, *_msg|
        if (1..10).include? s.to_i
          sleep(s.to_i)
        else
          sleep(5)
        end
        event.message.delete
      end

      command(:encodemsg,
              aliases: %i[encode 🔒 spoiler spoilers],
              description: 'Encode a message (with ROT13).',
              usage: 'encode <#channel_name | channel_id (optional)> <message>',
              min_args: 1) do |event, channel, *msg|
        if event.channel.pm?
          user_id = event.message.user.id
          aliases = CFG.channel_aliases
          @pm = false

          # Channel ID: 18 digits
          case channel
          when /\d{18}/
            @channel_id = channel.to_i
            plainmsg = msg.join(' ')

            # Channel name: hastag and 1-100 non-whitespace characters
          when /#\S{1,100}/
            channel[0] = ''
            if aliases.key?(channel)
              @channel_id = aliases[channel].to_i
            else
              @channel_id = BOT.find_channel(channel)
              if @channel_id.empty?
                event.<< 'The channel was not found. Encoded message: '
                @pm = true
              else
                @channel_id = @channel_id.first.id.to_i
              end
            end
            plainmsg = msg.join(' ')
            # Private Messages
          else
            plainmsg = "#{channel} #{msg.join(' ')}"
            @pm = true
          end

          encoded_msg = plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
          # TODO: Multiple encoding methods.
          # encoded_msg = case emethod
          #               when 'rot13'
          #                 plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
          #               when 'sha512'
          #                 Digest::SHA2.new(512).hexdigest(plainmsg)
          #               else
          #                 plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
          #               end

          if !@pm
            # Hardcoded (for the time being) permission check for a specific channel.
            server_id = BOT.channel(@channel_id).server.id
            if aliases['anime'].to_i == @channel_id && !event.author.on(server_id).role?(411_305_301_036_498_946)
              event.<< 'You do not have enough permissions to send this to to the weeb kingdom.'
            else
              m = BOT.send_message(@channel_id.to_i, "\u2063<@#{user_id.to_i}>: #{encoded_msg}")
              m.create_reaction('🔓')
            end

          else
            event.<< "⁣#{encoded_msg}"
          end
        else
          event.send_temporary_message('This command only works in DMs!', 5)
          event.message.delete
        end
      end
    end
  end
end
