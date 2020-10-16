module TohsakaBot
  module Commands
    module Winner
      extend Discordrb::Commands::CommandContainer
      command(:winner,
              aliases: %i[voittaja],
              description: 'Makes the user a winner for a week.',
              usage: 'winner <user>',
              min_args: 1,
              permission_level: 750) do |event|

        user_id = event.message.mentions[0].id
        role_id = CFG.winner_role

        if BOT.member(event.server, user_id).role?(role_id)
          Discordrb::API::Server.remove_member_role("Bot #{AUTH.bot_token}", event.channel.server.id, user_id, role_id)
          TohsakaBot.delete_temporary_role_db(user_id, role_id)
          event.respond('So a loser then.')
        else
          TohsakaBot.give_temporary_role(event, role_id, user_id)
          event.respond('Winner has been selected!')
        end
      end
    end
  end
end
