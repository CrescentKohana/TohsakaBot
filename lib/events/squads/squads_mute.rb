# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsMute
      extend Discordrb::EventContainer
      reaction_add(emoji: %w[❌ 🚫 🔕]) do |event|
        next if event.channel.pm? || event.user.bot_account
        next unless Time.now.to_i <= event.message.timestamp.to_i + 3600

        role_id = nil
        event.message.role_mentions.each do |rm|
          if TohsakaBot.role_cache[event.server.id][:roles].keys.include? rm.id.to_i
            role_id = rm.id.to_i
            break
          end
        end
        next if role_id.nil?
        next unless BOT.member(event.server.id, event.user.id)&.role?(role_id)

        if event.user.id == event.message.author.id
          Discordrb::API::Channel.delete_user_reaction(
            "Bot #{AUTH.bot_token}", event.channel.id, event.message.id, event.emoji.name, event.message.author.id
          )
          next
        end

        durations = { "❌" => 1, "🚫" => 6, "🔕" => 24 }
        db = YAML::Store.new("data/squads_mute.yml")
        i = 1
        db.transaction do
          i += 1 while db.root?(i)
          db[i] = {
            'time' => Time.now,
            'hours' => durations[event.emoji.name],
            'user' => event.user.id,
            'server' => event.server.id,
            'role' => role_id
          }
          db.commit
        end

        Discordrb::API::Server.remove_member_role(
          "Bot #{AUTH.bot_token}",
          event.channel.server.id,
          event.user.id,
          role_id
        )
      end
    end
  end
end
