# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Fun
      extend Discordrb::Commands::CommandContainer

      # Ratelimit for users. 15 times in a span of 60 seconds (1s delay between each).
      # TODO: Maybe move these to a single file across all commands?
      bucket :cf, limit: 15, time_span: 60, delay: 1
      bucket :icecube, limit: 1, time_span: 10, delay: 1

      command(:number,
              aliases: TohsakaBot.get_command_aliases('commands.fun.number.aliases'),
              description: I18n.t(:'commands.fun.number.description'),
              usage: I18n.t(:'commands.fun.number.usage'),
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, one, two|
        command = CommandLogic::Number.new(event, one, two)
        event.respond(command.run[:content])
      end

      command(:coinflip,
              aliases: TohsakaBot.get_command_aliases('commands.fun.coinflip.aliases'),
              description: I18n.t(:'commands.fun.coinflip.description'),
              usage: I18n.t(:'commands.fun.coinflip.usage'),
              bucket: :cf,
              rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, times|
        command = CommandLogic::Coinflip.new(event, times)
        response = command.run
        event.respond(response[:content], nil, response[:embeds]&.first)
      end

      command(:fgo,
              aliases: TohsakaBot.get_command_aliases('commands.fun.fgo.aliases'),
              description: I18n.t(:'commands.fun.fgo.description'),
              usage: I18n.t(:'commands.fun.fgo.usage')) do |event, amount, currency, verbose|
        command = CommandLogic::FGO.new(event, amount, currency, verbose)
        response = command.run
        event.respond(response[:content], nil, response[:embeds]&.first)
      end

      command(:chaos,
              aliases: TohsakaBot.get_command_aliases('commands.fun.chaos.aliases'),
              description: I18n.t(:'commands.fun.chaos.description'),
              usage: I18n.t(:'commands.fun.chaos.usage'),
              min_args: 1) do |event, *txt|
        command = CommandLogic::Chaos.new(event, txt)
        event.respond(command.run[:content])
      end

      command(:doubles,
              aliases: %i[tuplat tuplilla tuplil dips dubs duoil duoilla duuoil duuoilla],
              description: 'Doubles.',
              usage: '',
              bucket: :cf,
              rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event|
        number = rand(0..99)
        name = BOT.member(event.server, event.author.id).display_name

        identifier = "\u200B" * 2
        TohsakaBot.send_message_with_reaction(
          event.channel.id,
          '🎲',
          "**#{number.to_s.rjust(2, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}",
          event.message
        )
      end

      command(:triples,
              aliases: %i[triplat triploilla tripla triploil trips],
              description: 'Triples.',
              usage: '',
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event|
        number = rand(0..999)
        name = BOT.member(event.server, event.author.id).display_name

        identifier = "\u200B" * 3
        TohsakaBot.send_message_with_reaction(
          event.channel.id,
          '🎲',
          "**#{number.to_s.rjust(3, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}",
          event.message
        )
      end

      command(:quads,
              aliases: %i[quads quad quadeil quadeilla quattroilla quattrot quattroilla
                          quattroil neljä nelosilla nelosil quadseilla quadseil tetra tetras tetroil tetroilla],
              description: 'Quads.',
              usage: '',
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event|
        number = rand(0..9999).to_s
        name = BOT.member(event.server, event.author.id).display_name
        user_id = event.message.author
        role_id = CFG.mvp_role.to_i

        identifier = "\u200B" * 4
        TohsakaBot.send_message_with_reaction(
          event.channel.id,
          '🎲',
          "**#{number.rjust(4, '0')}**  `#{name.strip_mass_mentions.sanitize_string}`#{identifier}",
          event.message
        )

        if /(\d)\1{3}/.match?(number)
          name = BOT.member(event.server, event.author.id).display_name
          TohsakaBot.give_temporary_role(event, role_id, user_id, 7, 'Quads')
          event.respond("🎉 @here #{name} HAS GOT QUADS! 🎉")
        end
      end

      command(:quints,
              aliases: %i[pentas penta quint quinteil quinteilla pentoil pentoilla
                          pentat quintit vitoset viisi five fives],
              description: 'Quints.',
              usage: '',
              bucket: :cf, rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event|
        number = rand(0..99_999).to_s
        name = BOT.member(event.server, event.author.id).display_name
        user_id = event.message.author
        role_id = CFG.mvp_role.to_i

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

      command(:icecubes,
              aliases: %i[🧊 icecubemachine icecubes icecube ic jääpalakone jääpala jääpalat],
              description: 'Timer by simulating melting icecubes.',
              usage: "Use 'icecube <how many (<= 300)> <[D]iscord | [u]nicode>",
              bucket: :icecube,
              rate_limit_message: 'No cubes for you! Wait %time%s.') do |event, icecube_count, type|
        event.message.delete

        icecube_count = '1' if icecube_count.nil?

        if /\A\d+\z/.match(icecube_count)
          icecube_count = icecube_count.to_i
        else
          event.respond('Have water instead 💧')
          break
        end

        icecube_count = 900 if icecube_count > 900

        if icecube_count > 100 || (!type.nil? && (type.downcase == 'unicode' || type.downcase == 'u'))
          cube = '\\🧊'
          water = '\\💧'
          # steam = "\\☁"
        else
          cube = '🧊'
          water = '💧'
          # steam = "☁"
        end

        cube_array = Array.new(icecube_count, cube)
        iterations = 0

        timer_msg = event.respond("\n`#{10 * iterations}s ⏲ #{event.author.display_name}`")
        ice_msg = event.respond(cube_array.join.to_str)

        while cube_array.include? cube
          iterations += 1

          cube_array.collect! do |e|
            if e == cube
              Random.new.rand(1..10) > 5 ? water : e
              # elsif e == water
              #   (Random.new.rand(1..10) == 1) ? steam : e
            else
              e
            end
          end

          melted = cube_array.count { |e| e == water }

          sleep(10)
          timer_msg.edit("\n`#{melted}/#{icecube_count} 🧊 melted in #{10 * iterations}s ⏲ #{event.author.display_name}`")
          ice_msg.edit(cube_array.join.to_str)
        end

        while cube_array.include? water
          iterations += 1
          cube_array.collect! do |e|
            if e == water
              Random.new.rand(1..10) > 5 ? '' : e
            else
              e
            end
          end

          vaporized = if cube_array.length.positive?
                        cube_array.length - cube_array.count do |e|
                          e == water
                        end
                      else
                        icecube_count
                      end

          sleep(10)
          timer_msg.edit(
            "\n`#{icecube_count}/#{icecube_count} 🧊 melted"\
          " and #{vaporized}/#{icecube_count} 💧 vaporized in #{10 * iterations}s ⏲ #{event.author.display_name}`"
          )
          ice_msg.edit(cube_array.join.to_str) if vaporized != cube_array.length
        end

        ice_msg.delete
        sleep(120)
        timer_msg.delete
        break
      end

      command(:neko,
              aliases: %i[cat],
              description: 'A cat.',
              usage: 'neko <type>',
              bucket: :cf,
              rate_limit_message: 'Calm down! You are ratelimited for %time%s.') do |event, type|
        if TohsakaBot.neko_types.include?(type.to_s)
          url = TohsakaBot.get_neko(type)
          break unless URI::DEFAULT_PARSER.make_regexp.match?(url)

          reply = if !event.channel.nsfw && !TohsakaBot.neko_types(nsfw: false).include?(type.to_s)
                    "**NSFW** ||#{url}||"
                  else
                    url
                  end
          event.<< reply
        elsif TohsakaBot.neko_txt_types.include?(type.to_s)
          msg = TohsakaBot.get_neko(type)
          event.<< msg
        else
          event.respond "**img**```#{TohsakaBot.neko_types.join(' ')}```**txt**```#{TohsakaBot.neko_txt_types.join(' ')}```"
        end
      end


    end
  end
end
