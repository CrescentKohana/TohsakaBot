# frozen_string_literal: true

module TohsakaBot
  module Events
    module PollVote
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^choice\d{1,2}:.*/) do |event|
        next if event.user.bot_account

        poll_id = event.message.id
        user_id = event.user.id
        choice = event.custom_id.split(":", 2)
        choice[0].slice!('choice')

        response = TohsakaBot.poll_cache.vote(poll_id, user_id, choice[0])

        if response[:votes]
          original_msg_content = event.message.content.gsub(/ `Votes: \d+`$/, "") + " `Votes: #{response[:votes]}`"
          Discordrb::API::Channel.edit_message(
            "Bot #{AUTH.bot_token}",
            event.channel.id,
            event.message.id,
            original_msg_content,
            false,
            nil,
            event.message.components
          )
        end

        if response[:content].nil?
          event.defer_update
        else
          event.respond(content: response[:content], ephemeral: true) unless response[:content].nil?
        end
      end
    end
  end
end
