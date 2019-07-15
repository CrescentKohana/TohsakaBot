module TohsakaBot
  module Commands
    module Doubles
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:doubles,
              aliases: %i[tuplat tuplilla tuplil dips],
              description: 'Doubles.',
              usage: '',
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event|

        number = rand(0..99)
        name = BOT.member(event.server, event.author.id).display_name

        identifier = "\u200B" * 2
        Kernel.send_message_with_reaction(BOT, event.channel.id, '🎲',
                                          '**' + number.to_s.rjust(2, '0') +
                                          '**  `' + name.strip_mass_mentions.sanitize_string + '`' + identifier)
      end
    end
  end
end
