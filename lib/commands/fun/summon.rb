module TohsakaBot
  module Commands
    module Summon
      extend Discordrb::Commands::CommandContainer
      bucket :commandseal, limit: 3, time_span: 3600, delay: 10
      command(:summon,
              aliases: %i[],
              description: 'Summon',
              usage: 'remind <servant>',
              min_args: 1,
              bucket: :commandseal, rate_limit_message: "Your command seals are on cooldown for %time%s!") do |e, servant|

        # Prototype of FATE (守護英霊召喚システム・フェイト).
        wh = Discordrb::API::Channel.create_webhook("Bot #{AUTH.bot_token}", e.channel.id, "Summoned Servant", nil, "I summon thee!")
        id = JSON.parse(wh)['id']
        token = JSON.parse(wh)['token']
        wh = Discordrb::Webhooks::Client.new(id: id, token: token)

        if servant == "saber"
        wh.execute {|msg|
          msg.content = "I have been summoned!"
          msg.username = "Saber"
          msg.avatar_url = "https://vignette.wikia.nocookie.net/typemoon/images/a/a1/SaberArtGOStage4.png/revision/latest"
          msg.add_embed do |embed|
            embed.colour = 0x4065B4
            embed.timestamp = Time.now
            embed.title = ''
            embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://vignette.wikia.nocookie.net/typemoon/images/1/11/SaberArtGoStage2.png/revision/latest/')
          end
        }
        elsif servant == "lancer"
        wh.execute {|msg|
          msg.content = "I have been summoned!"
          msg.username = "Lancer"
          msg.avatar_url = "https://vignette.wikia.nocookie.net/fategrandorder/images/6/6f/Cuchulainn4.png/revision/latest"
          msg.add_embed do |embed|
            embed.colour = 0x053E81
            embed.timestamp = Time.now
            embed.title = 'Alpha male'
            embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://vignette.wikia.nocookie.net/typemoon/images/5/5d/LAncerCuChuGOStage3.png/revision/latest/')
          end
        }
        elsif servant == "archer"
          wh.execute {|msg|
            msg.content = "I have been summoned!"
            msg.username = "Archer"
            msg.avatar_url = "https://vignette.wikia.nocookie.net/typemoon/images/7/70/ArcherEMIYAGOStage4.png/revision/latest"
            msg.add_embed do |embed|
              embed.colour = 0xD03F3E
              embed.timestamp = Time.now
              embed.title = 'The Archer class really is made up of Archers!'
              embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://vignette.wikia.nocookie.net/typemoon/images/0/04/ArcherEMIYAGOStage3.png/revision/latest')
            end
          }
        end

        Discordrb::API::Webhook.delete_webhook("Bot #{AUTH.bot_token}", id, "Thy work here is done.")
      end
    end
  end
end
