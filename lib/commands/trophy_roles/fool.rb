module TohsakaBot
  module Commands
    module Fool
      extend Discordrb::Commands::CommandContainer
      command(:fool,
              description: 'Gives user a temporary role of fool.',
              usage: 'fool <user> <duration in days> <reason>',
              min_args: 2,
              permission_level: 750) do |event, _user, days, *reason|

        user_id = event.message.mentions[0].id.to_i

        TohsakaBot.give_temporary_role(event, CFG.fool_role, user_id, days, reason)
        event.respond(
          "#{event.message.mentions[0].username} has been decided to be a fool for #{days} day#{"s" if days.to_i > 1}."
        )
      end
    end
  end
end
