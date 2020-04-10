module TohsakaBot
  module Async
    module TempRoleNoMore

      Thread.new do
        loop do

          role_db = YAML.load_file('data/temporary_roles.yml')
          timen = Time.now.to_i

          role_db.each do |key, value|
            if timen >= value['time'].to_i + 604800

              uid = value['user'].to_i
              sid = value['server'].to_i
              rid = value['role'].to_i

              Discordrb::API::Server.remove_member_role("Bot #{AUTH.bot_token}", sid, uid, rid)

              rstore = YAML::Store.new('data/temporary_roles.yml')
              rstore.transaction do
                rstore.delete(key)
                rstore.commit
              end
            end
          end
          sleep(10)
        end
      end
    end
  end
end
