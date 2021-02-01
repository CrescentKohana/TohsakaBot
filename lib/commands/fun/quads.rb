module TohsakaBot
  module Commands
    module Quads
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:quads,
              aliases: %i[quads quad quadeil quadeilla quattroilla
              quattroil neljä nelosilla nelosil quadseilla quadseil tetra tetras tetroil tetroilla],
              description: 'Quads.',
              usage: '',
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.") do |event|

        number = rand(0..9999).to_s
        name = BOT.member(event.server, event.author.id).display_name
        user_id = event.message.author
        role_id = CFG.winner_role.to_i

        identifier = "\u200B" * 4
        TohsakaBot.send_message_with_reaction(
            event.channel.id,
            '🎲',
            "**#{number.rjust(4, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}"
        )

        if /(\d)\1{3}/.match?(number)
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_temporary_role(event, role_id, user_id)
          event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
        end
      end
    end
  end
end
