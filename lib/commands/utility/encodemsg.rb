module TohsakaBot
  module Commands
    module EncodeMsg
      extend Discordrb::Commands::CommandContainer
      command(:encodemsg,
              aliases: %i[encode 🔒],
              description: 'Encode a message (with ROT13).',
              usage: 'encode <channel (opt)> <message>',
              rescue: "Something went wrong!\n`%exception%`") do |event, chan, *msg|

        if event.channel.pm?
          uid = event.message.user.id
          aliases = $settings['channel_aliases']

          if chan =~ /\d{18}/
            plainmsg = msg.join(' ')
            @to_where = 1
          elsif chan[0] == '#'
            chan[0] = ''
            if aliases.key?(chan)
              chan = aliases[chan].to_i
            else
              channels = BOT.find_channel(chan)
              @to_where = 1
            end
            plainmsg = msg.join(' ')
            @to_where = 1
          else
            plainmsg = chan + ' ' + msg.join(' ')
            @to_where = 2
          end

          encoded_msg = plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')

          # TODO: Multiple encoding methods.
          # encoded_msg = case emethod
          #              when 'rot13'
          #                plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
          #              when 'md5'
          #                plainmsg.tr('perkele', 'saatana')
          #              else
          #                plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
          #              end


          if @to_where == 1
            cid = if chan.is_a? Integer
                    chan
                  else
                    channels[0].id
                  end

            # Hardcoded (for the time being) permission check for a specific channel. #server
            server_id = BOT.channel(cid).server.id
            if aliases['anime'].to_i == cid && !event.author.on(server_id).role?(411305301036498946)
              event.<< "You do not have enough permissions to send this to to the weeb kingdom."
            else
              m = BOT.send_message(cid.to_i, "\u2063<@#{uid.to_i}>: #{encoded_msg}")
              m.create_reaction('🔓')
            end

          else
            event.<< "\u2063" + encoded_msg
          end
        else
          event.send_temporary_message('This command only works in DMs!', 5)
          event.message.delete
        end
      end
    end
  end
end
