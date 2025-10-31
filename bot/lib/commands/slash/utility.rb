# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Utility
      BOT.application_command(:utility).subcommand('roll_probability') do |event|
        command = CommandLogic::RollProbability.new(
          event,
          event.options['chance'],
          event.options['rolls'],
          event.options['hits']
        )
        event.respond(content: command.run[:content])
      end

      BOT.application_command(:utility).subcommand('getsauce') do |event|
        command = CommandLogic::GetSauce.new(event, event.options['link'])
        response = command.run
        event.respond(content: response[:content], embeds: response[:embeds])
      end

      BOT.application_command(:utility).subcommand('quickie') do |event|
        event.respond(content: 'Slash command version currently not supported. Use ?quickie')
        # reply = event.respond(content: event.options['message'], wait: true)
        # sleep(CommandLogic::Quickie.duration(event.options['duration']))
        # reply.delete
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

      BOT.application_command(:utility).subcommand('poll') do |event|
        command = CommandLogic::Poll.new(
          event,
          event.options['question'],
          event.options['choices'],
          event.options['duration'],
          event.options['multi'],
          event.options['template'],
          event.options['type']
        )

        response = command.run
        reply = event.respond(
          content: response[:content],
          components: response[:components],
          allowed_mentions: false,
          wait: true
        )

        TohsakaBot.poll_cache.create(
          reply.id,
          reply.channel.id,
          response[:poll_data][:question],
          response[:poll_data][:choices],
          response[:poll_data][:duration],
          response[:poll_data][:multi]
        )
      end
    end
  end
end

