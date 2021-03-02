module TohsakaBot
  module Async
    module PeriodicalTempRoleDeletion
      Thread.new do
        loop do
          role_db = YAML.load_file('data/temporary_roles.yml')
          time_now = Time.now.to_i
          to_be_removed = {}

          role_db.each do |_k, v|
            user_id = v['user'].to_i
            role_id = v['role'].to_i

            if time_now >= v['time'].to_i + (v['duration'] * 24 * 60 * 60)
              server_id = v['server'].to_i

              to_be_removed[[user_id, role_id]] = server_id unless (to_be_removed[{ user_id => role_id }]).zero?
            else
              to_be_removed[[user_id, role_id]] = 0
            end
          end

          to_be_removed.each do |k, v|
            Discordrb::API::Server.remove_member_role("Bot #{AUTH.bot_token}", v, k[0], k[1]) unless v.zero?
          end
          sleep(60)
        end
      end
    end
  end
end
