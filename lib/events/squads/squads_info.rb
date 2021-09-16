# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsInfo
      extend Discordrb::EventContainer
      reaction_add(emoji: '❓') do |event|
        next if event.channel.pm? || event.user.bot_account

        roles = TohsakaBot.role_cache[event.server.id][:roles]
        parsed_roles = ''.dup
        roles.each do |_id, role|
          next if role[:group_size].zero?

          parsed_roles << "`#{role[:name]}` "
        end

        BOT.pm_channel(event.user.id).send_message(I18n.t(:'events.squads.info', roles: parsed_roles))
      end
    end
  end
end
