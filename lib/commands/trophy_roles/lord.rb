module TohsakaBot
  module Commands
    module Lord
      extend Discordrb::Commands::CommandContainer
      command(:lord,
              description: 'Gives user a temporary role of lord.',
              usage: 'lord <user> <duration in days> <reason>',
              min_args: 2,
              permission_level: 750) do |event, days, *reason|

        user_id = event.message.mentions[0].id
        role_id = CFG.lord_role

        TohsakaBot.give_temporary_role(event, role_id, user_id, days, reason)
        event.respond(
          "#{event.message.mentions[0].display_name} has been decided to be a lord for #{days} day#{"s" if days > 1}."
        )
      end
    end
  end
end
