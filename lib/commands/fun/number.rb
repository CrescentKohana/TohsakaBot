# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Number
      extend Discordrb::Commands::CommandContainer
      bucket :cf, limit: 15, time_span: 60, delay: 1
      command(:number,
              aliases: %i[numbers num numero single singles singleil singlet singleillä],
              description: 'A random number.',
              usage: 'number <start> <end> (default 0-9)',
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, one, two|
        name = BOT.member(event.server, event.author.id).display_name.strip_mass_mentions.sanitize_string

        if (one.nil? && two.nil?) || (!Integer(one, exception: false) || !Integer(two, exception: false))
          one = 0
          two = 9
        end

        if one.to_i < -100_000_000 || two.to_i > 100_000_000
          event.<< "Don't break the bot (range: -100000000 - 100000000)."
          break
        end

        two, one = one, two if one.to_i > two.to_i

        number = rand(one.to_i..two.to_i)
        event.channel.send_embed do |embed|
          embed.colour = 0x36393F
          embed.add_field(
            name: "**#{number}** 🎲 (#{one}..#{two})",
            value: "[#{name}](https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{event.message.id})"
          )
        end
      end
    end
  end
end
