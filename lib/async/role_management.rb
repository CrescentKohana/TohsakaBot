module TohsakaBot
  module Async
    module RoleManagement
      Thread.new do
        loop do
          role_db = YAML.load_file('data/temporary_roles.yml')
          mute_db = YAML.load_file('data/squads_mute.yml')
          time_now = Time.now.to_i

          unless role_db.nil? || !role_db
            role_db.each do |k, v|
              user_id = v['user'].to_i
              role_id = v['role'].to_i

              next if v.nil? || !v["duration"]
              next unless time_now >= v['time'].to_i + (v['duration'] * 24 * 60 * 60)

              Discordrb::API::Server.remove_member_role(
                "Bot #{AUTH.bot_token}", v['server'].to_i, user_id, role_id
              )

              rstore = YAML::Store.new('data/temporary_roles.yml')
              rstore.transaction do
                rstore[k]["duration"] = false
                rstore.commit
              end
            end
          end

          unless mute_db.nil? || !mute_db
            mute_db.each do |k, v|
              user_id = v['user'].to_i
              role_id = v['role'].to_i

              next if v.nil?
              next unless time_now >= v['time'].to_i + (v['hours'].to_i * 60 * 60)

              Discordrb::API::Server.add_member_role(
                "Bot #{AUTH.bot_token}", v['server'].to_i, user_id, role_id
              )

              rstore = YAML::Store.new('data/squads_mute.yml')
              rstore.transaction do
                rstore.delete(k)
                rstore.commit
              end
            end
          end

          sleep(60)
        end
      end
    end
  end
end
