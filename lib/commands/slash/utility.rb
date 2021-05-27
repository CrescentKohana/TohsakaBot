# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Utility
      BOT.application_command(:utility).subcommand('getsauce') do |event|
        command = CommandLogic::GetSauce.new(event, event.options['link'])
        response = command.run
        event.respond(content: response[:content], embeds: response[:embeds])
      end

      BOT.application_command(:utility).subcommand('encode_message') do |event|
        command = CommandLogic::EncodeMsg.new(event, event.options['algorithm'], event.options['message'])
        response = command.run
        if event.options['ephemeral']
          event.respond(content: response[:content], ephemeral: true)
          message = "<@!#{event.user.id}>: #{response[:content]}"
          TohsakaBot.send_message_with_reaction(response[:channel_id], '🔓', message)
        else
          reply = event.respond(content: response[:content], wait: true)
          Discordrb::API::Channel.create_reaction("Bot #{AUTH.bot_token}", reply.channel_id, reply.id, '🔓')
        end
      end
    end
  end
end
