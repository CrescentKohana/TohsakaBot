# frozen_string_literal: true

module TohsakaBot
  module Events
    module SquadsMute
      extend Discordrb::EventContainer
      reaction_add(emoji: %w[❌ 🚫 🔕]) do |event|
        next if event.channel.pm? || event.user.bot_account
        next if event.message.content&.first == '#'
        next if event.message.role_mentions.empty?

        role_id = nil
        event.message.role_mentions.each do |rm|
          if TohsakaBot.server_cache[event.server.id][:roles].keys.include? rm.id.to_i
            role_id = rm.id.to_i
            break
          end
        end
        next if role_id.nil?

        previous_mute = false
        mute_db = YAML.load_file('data/squads_mute.yml', permitted_classes: [Time])
        mute_db.each do |k, v|
          next if v.nil?
          next if v['role'].to_i != role_id || v['user'].to_i != event.user.id

          previous_mute = true
          db = YAML::Store.new('data/squads_mute.yml')
          db.transaction do
            db.delete(k)
            db.commit
          end
        end

        current_role = BOT.member(event.server.id, event.user.id)&.role?(role_id)

        if previous_mute || current_role
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
        end

        if current_role
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
end
