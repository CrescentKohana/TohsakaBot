module TohsakaBot
  module Commands
    module Number
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:number,
              aliases: %i[numbers num numero single singles singleil singlet singleillä],
              description: 'A random number.',
              usage: 'number <start> <end> (default 0-9)',
              bucket: :cf, rate_limit_message: "Calm down! You are ratelimited for %time%s.",
              rescue: "Something went wrong!\n`%exception%`") do |event, one, two|

        name = BOT.member(event.server, event.author.id).display_name.strip_mass_mentions.sanitize_string

        # Ruby 2.6.0 enables casting to an integer without raising an exception, and will return nil if the cast fails.
        # https://rubyreferences.github.io/rubychanges/2.6.html#numeric-methods-have-exception-argument
        if (one.nil? && two.nil?) || (!Integer(one, exception: false) || !Integer(two, exception: false))
          event.<< '**' + rand(0..9).to_s + '**  `' + name + '`'
          break
        end

        if one.to_i < -100000000 || two.to_i > 100000000
          event.<< "Don't break the bot (range is -100000000 - 100000000)."
          break
        end

        if one.to_i > two.to_i then two,one = one,two end

        number = rand(one.to_i..two.to_i)
        event.<< '**' + number.to_s + '**  `' + name + '`'
      end
    end
  end
end
