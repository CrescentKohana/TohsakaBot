# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsHelper
      extend Discordrb::EventContainer

      roles_regex = []
      TohsakaBot.role_cache.each do |_sid, server|
        server[:roles].each do |rid, _role|
          roles_regex << /.*<@&#{rid}>.*/
        end
      end

      message(content: roles_regex) do |event|
        next if event.channel.pm?
        next if event.message.content&.first == '#'

        emoji = %w[✅ ❌ 🚫 🔕 ❓]
        emoji.each do |e|
          event.message.create_reaction(e)
        end
      end
    end
  end
end
