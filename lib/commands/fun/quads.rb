module TohsakaBot
  module Commands
    module Quads
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:quads,
              aliases: %i[quads quad quadeil quadeilla quattroilla
              quattroil neljä nelosilla nelosil quadseilla quadseil],
              description: 'Quads.',
              usage: '',
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event|

        number = rand(0..9999)
        name = BOT.member(event.server, event.author.id).display_name

        identifier = "\u200B" * 4
        Kernel.send_message_with_reaction(BOT, event.channel.id, '🎲',
                                          '**' + number.to_s.rjust(4, '0') +
                                          '**  `' + name.strip_mass_mentions.sanitize_string + '`' + identifier)

        if number =~ /(\d)\1{3}/
          name = BOT.member(event.server, event.author.id).display_name
          Kernel.give_temporary_role(event, $settings['winner_role'])
          event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
        end
      end
    end
  end
end
