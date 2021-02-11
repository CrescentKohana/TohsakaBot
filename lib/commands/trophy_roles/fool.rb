module TohsakaBot
  module Commands
    module Fool
      extend Discordrb::Commands::CommandContainer
      command(:fool,
              description: 'Gives user a temporary role of fool.',
              usage: 'fool <user> <duration in days> <reason>',
              min_args: 2,
              permission_level: 750) do |event, days, *reason|

        user_id = event.message.mentions[0].id
        role_id = CFG.fool_role

        TohsakaBot.give_temporary_role(event, role_id, user_id, days, reason)
        event.respond(
          "#{event.message.mentions[0].display_name} has been selected as a fool for #{days} day#{"s" if days > 1}."
        )
      end
    end
  end
end
