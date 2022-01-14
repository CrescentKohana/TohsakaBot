# frozen_string_literal: true

module TohsakaBot
  module Events
    module TimeoutVote
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^timeout:(?:yes|no)/) do |event|
        next if event.user.bot_account
        next if event.message.channel.pm?

        voter_id = event.user.id
        next unless TohsakaBot.permissions.able?(voter_id, 'trusted', :role)

        member_id = event.message.content.match(/<@!(\d+)>/).captures[0]
        choice = event.custom_id.split(":", 2)[1]
        response = TohsakaBot.timeouts_cache.vote(member_id, voter_id, choice.to_sym)

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
          event.respond(content: response[:content], ephemeral: true)
        end
      end
    end
  end
end
