module TohsakaBot
  module Commands
    module Number
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:number,
              aliases: %i[numbers num numero single singles],
              description: 'A random number.',
              usage: 'number <start> <end>',
              min_args: 2,
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event, one, two|

        if one.to_i < -100000000 || two.to_i > 100000000
          event.<< "Don't break the bot."
          break
        end

        if one.to_i > two.to_i then two,one = one,two end

        name = BOT.member(event.server, event.author.id).display_name
        number = rand(one.to_i..two.to_i)
        event.<< '**' + number.to_s + '**  `' + name.strip_mass_mentions.sanitize_string + '`'
      end
    end
  end
end
