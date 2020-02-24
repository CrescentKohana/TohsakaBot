module TohsakaBot
  module Commands
    module Loser
      extend Discordrb::Commands::CommandContainer
      command(:loser,
              aliases: %i[retard vammanen],
              description: 'Makes the user a loser for a week.',
              usage: 'loser <user>',
              min_args: 1,
              allowed_roles: [299992716480348160], # Owner Role ID
              rescue: "Something went wrong!\n`%exception%`") do |event, username|

        user_id = event.message.mentions[0].id
        role_id = CFG.loser_role

        if BOT.member(event.server, user_id).role?(role_id)
          Discordrb::API::Server.remove_member_role("Bot #{CFG.bot_token}", event.channel.server.id, user_id, role_id)
          Kernel.delete_temporary_role_db(user_id, role_id)
          event.respond('Ex-retard.')
        else
          Kernel.give_temporary_role(event, role_id, user_id)
          event.respond('Retard has been selected!')
        end
      end
    end
  end
end
