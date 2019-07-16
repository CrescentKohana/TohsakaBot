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
        role_id = $settings['winner_role'].to_i

        if BOT.member(event.server, user_id).role?(role_id)
          Discordrb::API::Server.remove_member_role("Bot #{$config['bot_token']}", event.channel.server.id, user_id, role_id)
          Kernel.delete_temporary_role_db(user_id, role_id)
          event.respond('So a loser then.')
        else
          Kernel.give_temporary_role(event, role_id)
          event.respond('Winner has been selected!')
        end
      end
    end
  end
end