module TohsakaBot
  module Commands
    module EncodeMsg
      extend Discordrb::Commands::CommandContainer
      command(:encodemsg,
              aliases: %i[encode 🔒],
              description: 'Encode a message (with ROT13).',
              usage: 'encode <#channel_name | channel_id (optional)> <message>',
              min_args: 1) do |event, channel, *msg|

        if event.channel.pm?
          user_id = event.message.user.id
          aliases = CFG.channel_aliases
          @pm = false

          # Channel ID: 18 digits
          if channel.match(/\d{18}/)
            @channel_id = channel.to_i
            plainmsg = msg.join(' ')

          # Channel name: hastag and 1-100 non-whitespace characters
          elsif channel.match(/#\S{1,100}/)
            channel[0] = ''
            if aliases.key?(channel)
              @channel_id = aliases[channel].to_i
            else
              @channel_id = BOT.find_channel(channel)
              if @channel_id.empty?
                event.<< "The channel was not found. Encoded message: "
                @pm = true
              else
                @channel_id = @channel_id.first.id.to_i
              end
            end
            plainmsg = msg.join(' ')
          # Private Messages
          else
            plainmsg = channel + ' ' + msg.join(' ')
            @pm = true
          end

          encoded_msg = plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')

          # TODO: Multiple encoding methods.
          encoded_msg = case emethod
                        when 'rot13'
                          plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
                        when 'sha512'
                          Digest::SHA2.new(512).hexdigest(plainmsg)
                        else
                          plainmsg.tr('a-zA-Z', 'n-za-mN-ZA-M')
                        end

          if !@pm
            # Hardcoded (for the time being) permission check for a specific channel.
            server_id = BOT.channel(@channel_id).server.id
            if aliases['anime'].to_i == @channel_id && !event.author.on(server_id).role?(411305301036498946)
              event.<< "You do not have enough permissions to send this to to the weeb kingdom."
            else
              m = BOT.send_message(@channel_id.to_i, "\u2063<@#{user_id.to_i}>: #{encoded_msg}")
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
