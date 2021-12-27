# frozen_string_literal: true

module TohsakaBot
  module Events
    module RockPaperScissors
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^rps:[012]/) do |event|
        next if event.user.bot_account

        choice = event.custom_id.split(":")[1].to_i
        result = TohsakaBot.rps_cache.play(event.message.message_reference["message_id"].to_i, event.user.id, choice)
        if result.nil?
          event.respond(content: I18n.t(:'errors.unexpected'), ephemeral: true)
          next
        end

        case result[:status]
        when :success
          event.respond(
            content: I18n.t(
              :'commands.fun.rockpaperscissors.response.pick',
              choice: I18n.t(:"commands.fun.rockpaperscissors.choice.c#{result[:content]}")
            ),
            ephemeral: true
          )
          next
        when :already_picked
          event.respond(
            content: I18n.t(
              :'commands.fun.rockpaperscissors.response.already_picked',
              choice: I18n.t(:"commands.fun.rockpaperscissors.choice.c#{result[:content]}")
            ),
            ephemeral: true
          )
          next
        when :in_progress
          event.respond(
            content: I18n.t(:'commands.fun.rockpaperscissors.response.in_progress'),
            ephemeral: true
          )
          next
        when :tie
          event.respond(
            content: I18n.t(
              :'commands.fun.rockpaperscissors.outcome.tie',
              p1: result[:content][0][:user_id],
              p2: result[:content][1][:user_id],
              choice:  I18n.t(:"commands.fun.rockpaperscissors.choice.c#{result[:content][0][:choice]}")
            )
          )
        when :win
          event.respond(
            content: I18n.t(
              :'commands.fun.rockpaperscissors.outcome.win',
              winner: result[:content][:winner][:user_id],
              loser: result[:content][:loser][:user_id],
              win_choice: I18n.t(:"commands.fun.rockpaperscissors.choice.c#{result[:content][:winner][:choice]}"),
              lose_choice: I18n.t(:"commands.fun.rockpaperscissors.choice.c#{result[:content][:loser][:choice]}")
            )
          )
        else
          event.respond(content: I18n.t(:'errors.unexpected'), ephemeral: true)
        end

        # Remove buttons after the game has ended.
        Discordrb::API::Channel.edit_message(
          "Bot #{AUTH.bot_token}",
          event.channel.id,
          event.message.id,
          event.message.content,
          false,
          nil,
          nil
        )
      end
    end
  end
end
