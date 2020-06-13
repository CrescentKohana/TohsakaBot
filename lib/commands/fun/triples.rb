module TohsakaBot
  module Commands
    module Triples
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:triples,
              aliases: %i[triplat triploilla tripla triploil trips],
              description: 'Triples.',
              usage: '',
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event|

        number = rand(0..999)
        name = BOT.member(event.server, event.author.id).display_name

        identifier = "\u200B" * 3
        TohsakaBot.send_message_with_reaction(
            event.channel.id,
            '🎲',
            "**#{number.to_s.rjust(3, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}"
        )
      end
    end
  end
end
