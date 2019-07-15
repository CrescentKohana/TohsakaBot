module TohsakaBot
  module Commands
    module Winner
      extend Discordrb::Commands::CommandContainer
      command(:winner,
              aliases: %i[voittaja],
              description: 'Makes the user a winner for a week.',
              usage: 'winner <user>',
              min_args: 1,
              allowed_roles: [299992716480348160],
              rescue: "Something went wrong!\n`%exception%`") do |event, username|

        user_id = event.message.mentions[0].id
        server_id = event.channel.server.id
        role_id = $settings['winner_role'].to_i
        # nickname = BOT.member(event.server, user_obj[0].id).nick

        if BOT.member(event.server, user_id).role?(role_id)
          Discordrb::API::Server.remove_member_role("Bot #{$config['bot_token']}", event.channel.server.id, user_id, role_id)
          # TODO: Delete from database. Not important though.
          event.respond('So a loser then.')
          break
        end
        Discordrb::API::Server.add_member_role("Bot #{$config['bot_token']}", event.channel.server.id, user_id, role_id)

        store = YAML::Store.new('data/temporary_roles.yml')
        store.transaction do
          i = 1
          while store.root?(i) do i += 1 end
          store[i] = {"time" => Time.now, "user" => user_id, "server" => server_id, "role" => role_id}
          store.commit
        end

        event.respond('Winner has been selected!')
      end
    end
  end
end