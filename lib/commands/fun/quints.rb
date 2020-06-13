module TohsakaBot
  module Commands
    module Quints
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:quints,
              aliases: %i[pentas penta quint quinteil quinteilla pentoil pentoilla
              pentat quintit vitoset viisi five fives],
              description: 'Quads.',
              usage: '',
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event|

        number = rand(0..99999)
        name = BOT.member(event.server, event.author.id).display_name
        user_id = event.message.author
        role_id = CFG.winner_role.to_i

        identifier = "\u200B" * 5
        TohsakaBot.send_message_with_reaction(
            event.channel.id,
            '🎲',
            "**#{number.to_s.rjust(5, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}"
        )

        if number.to_s =~ /(\d)\1{3}/
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_temporary_role(event, role_id, user_id)
          event.respond("🎉 @here #{name} HAS GOT QUINTS! 🎉")
        end
      end
    end
  end
end
