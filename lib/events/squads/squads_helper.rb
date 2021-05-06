# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsHelper
      extend Discordrb::EventContainer
      roles = JSON.parse(File.read('data/squads.json')).map { |r| /.*<@&#{r[1]["role_id"]}>.*/ }
      message(content: roles) do |event|
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
