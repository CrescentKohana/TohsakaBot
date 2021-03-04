module TohsakaBot
  module Async
    module PeriodicalTempRoleDeletion
      Thread.new do
        loop do
          role_db = YAML.load_file('data/temporary_roles.yml')
          next if role_db.nil? || !role_db

          time_now = Time.now.to_i
          role_db.each do |_k, v|
            user_id = v['user'].to_i
            role_id = v['role'].to_i

            next unless time_now >= v['time'].to_i + (v['duration'] * 24 * 60 * 60)
            next if v.nil?

            Discordrb::API::Server.remove_member_role(
              "Bot #{AUTH.bot_token}", v['server'].to_i, user_id, role_id
            )
          end
          sleep(60)
        end
      end
    end
  end
end
