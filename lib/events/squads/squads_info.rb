# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsInfo
      extend Discordrb::EventContainer
      reaction_add(emoji: '❓') do |event|
        next if event.channel.pm? || event.user.bot_account

        roles = JSON.parse(File.read("data/persistent/squads.json")).keys.join(' ')
        BOT.pm_channel(event.user.id).send_message(I18n.t(:'events.squads.info', roles: roles))
      end
    end
  end
end
