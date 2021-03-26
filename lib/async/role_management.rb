# frozen_string_literal: true

module TohsakaBot
  module Async
    module RoleManagement
      Thread.new do
        loop do
          role_db = YAML.load_file('data/temporary_roles.yml')
          mute_db = YAML.load_file('data/squads_mute.yml')
          timed_role_db = YAML.load_file('data/timed_roles.yml')
          now = Time.now

          unless role_db.nil? || !role_db
            role_db.each do |k, v|
              user_id = v['user'].to_i
              role_id = v['role'].to_i

              next if v.nil? || !v["duration"]
              next unless now.to_i >= v['time'].to_i + (v['duration'] * 24 * 60 * 60)

              Discordrb::API::Server.remove_member_role(
                "Bot #{AUTH.bot_token}", v['server'].to_i, user_id, role_id
              )

              db = YAML::Store.new('data/temporary_roles.yml')
              db.transaction do
                db[k]["duration"] = false
                db.commit
              end
            end
          end

          unless mute_db.nil? || !mute_db
            mute_db.each do |k, v|
              next if v.nil?

              user_id = v['user'].to_i
              role_id = v['role'].to_i
              next unless now.to_i >= v['time'].to_i + (v['hours'].to_i * 60 * 60)

              Discordrb::API::Server.add_member_role(
                "Bot #{AUTH.bot_token}", v['server'].to_i, user_id, role_id
              )

              db = YAML::Store.new('data/squads_mute.yml')
              db.transaction do
                db.delete(k)
                db.commit
              end
            end
          end

          unless timed_role_db.nil? || !timed_role_db
            timed_role_db.each do |k, v|
              next if v.nil?

              user_id = v[:user].to_i
              server_id = v[:server].to_i
              all_days = v[:times].map { |r| r[:day] }
              add_roles = nil

              v[:times].each do |range|
                today_id = Date.today.wday
                today = RoleController.days(table: true)[today_id]
                is_weekend = [0, 6].include?(today_id)
                next unless today.include?(range[:day])
                next if range[:day] == "weekday" && !is_weekend && all_days.include?(today[1])
                next if range[:day] == "weekend" && is_weekend && all_days.include?(today[1])

                start_time = range[:start].split(":")
                end_time = range[:end].split(":")

                start_time = Time.new(now.year, now.month, now.day, start_time[0], start_time[1], 0)
                end_time = Time.new(now.year, now.month, now.day, end_time[0], end_time[1], 0)

                inactive = v[:mode] == "inactive" && (start_time..end_time).cover?(now)
                active = v[:mode] == "active" && (start_time..end_time).cover?(now)

                add_roles = true if (active || !inactive) && now.to_i >= v[:activate_on].to_i
                add_roles = false if (!active || inactive) && now.to_i >= v[:activate_on].to_i
                next if add_roles.nil?

                db = YAML::Store.new('data/timed_roles.yml')
                db.transaction do
                  db[k][:activate_on] = end_time
                  db.commit
                end
              end
              next if add_roles.nil?

              v[:roles].each do |role|
                found_role = BOT.server(server_id).roles.find { |r| r.name == role }
                next if found_role.nil?

                if add_roles
                  muted = false
                  mute_db.each_value do |m|
                    next if m.nil?

                    if found_role == m['role'].to_i && user_id == m['user'].to_i
                      muted = true
                      next
                    end
                  end
                  next if muted

                  BOT.user(user_id).pm("Added role #{role}") # debug message
                  next if TohsakaBot::BOT.member(server_id, user_id)&.role?(found_role.id)

                  Discordrb::API::Server.add_member_role(
                    "Bot #{AUTH.bot_token}", server_id, user_id, found_role.id
                  )
                else
                  BOT.user(user_id).pm("Removed role #{role}") # debug message
                  next unless TohsakaBot::BOT.member(server_id, user_id)&.role?(found_role.id)

                  Discordrb::API::Server.remove_member_role(
                    "Bot #{AUTH.bot_token}", server_id, user_id, found_role.id
                  )
                end
              end
            end
          end
          sleep(20)
        end
      end
    end
  end
end
