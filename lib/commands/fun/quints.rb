# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Quints
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:quints,
              aliases: %i[pentas penta quint quinteil quinteilla pentoil pentoilla
                          pentat quintit vitoset viisi five fives],
              description: 'Quints.',
              usage: '',
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event|
        number = rand(0..99_999).to_s
        name = BOT.member(event.server, event.author.id).display_name
        user_id = event.message.author
        role_id = CFG.lord_role.to_i

        identifier = "\u200B" * 5
        TohsakaBot.send_message_with_reaction(
          event.channel.id,
          '🎲',
          "**#{number.rjust(5, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}",
          event.message
        )

        if /(\d)\1{4}/.match?(number)
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_temporary_role(event, role_id, user_id, 7, 'Quints')
          event.respond("🎉 @here #{name} HAS GOT QUINTS! 🎉")
        end
      end
    end
  end
end
