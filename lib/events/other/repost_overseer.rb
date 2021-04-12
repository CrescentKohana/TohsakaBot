# frozen_string_literal: true

module TohsakaBot
  module Events
    module RepostOverseer
      extend Discordrb::EventContainer
      message(content: TohsakaBot.url_regex) do |event|
        next if event.channel.pm?

        linked = TohsakaBot.url_match(event)

        unless linked.nil?
          user_obj = BOT.member(event.server, linked[:author_id])
          username = user_obj.nil? ? "Deleted user" : user_obj.username

          event.channel.send_embed do |embed|
            embed.colour = 0x36393F
            # embed.url = ""
            embed.add_field(
              name: '**WANHA**',
              value: "[#{username}](https://discord.com/channels/"\
                     "#{linked[:server_id]}/#{linked[:channel_id]}/#{linked[:msg_id]})"
            )
            embed.timestamp = linked[:timestamp]
          end
        end
      end
    end
  end
end
