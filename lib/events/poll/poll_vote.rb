# frozen_string_literal: true

module TohsakaBot
  module Events
    module PollVote
      rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      rate_limiter.bucket :poll_vote, delay: 1
      extend Discordrb::EventContainer

      BOT.button(custom_id: /^choice\d{1,2}:.*/) do |event|
        next if event.user.bot_account

        poll_id = event.message.id
        user_id = event.user.id
        choice = event.custom_id.split(":", 2)
        choice[0].slice!('choice')

        response = TohsakaBot.poll_cache.vote(poll_id, user_id, choice[0])
        event.respond(content: response, ephemeral: true)
      end
    end
  end
end
