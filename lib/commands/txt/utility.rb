# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Utility
      extend Discordrb::Commands::CommandContainer

      command(:rollprobability,
              aliases: %i[rollchance chanceroll rollp rollc],
              description: 'Returns the probability of getting k hits within n amount of rolls with the chance of p.',
              usage: 'rollprobability <chance in % (float|int)> <rolls (int)> <hits (int, default: 1)>',
              min_args: 2) do |event, chance, rolls, hits|
        command = CommandLogic::RollProbability.new(event, chance, rolls, hits)
        event.respond(command.run[:content])
      end

      command(:poll,
              aliases: TohsakaBot.get_command_aliases('commands.utility.poll.aliases'),
              description: I18n.t(:'commands.utility.poll.description'),
              usage: I18n.t(:'commands.utility.poll.usage'),
              min_args: 1) do |event, *input|
        options = TohsakaBot.command_parser(
          event, input,
          I18n.t(:'commands.utility.poll.help.banner'),
          I18n.t(:'commands.utility.poll.help.extra_help'),
          [:question, I18n.t(:'commands.utility.poll.help.question'), { type: :strings }],
          [:choices, I18n.t(:'commands.utility.poll.help.choices'), { type: :strings }],
          [:duration, I18n.t(:'commands.utility.poll.help.duration'), { type: :string }],
          [:multi, I18n.t(:'commands.utility.poll.help.multi'), { type: :boolean }]
          # [:type, I18n.t(:'commands.poll.help.type'), { type: :string }]
        )
        break if options.nil?

        question = options.question.nil? ? nil : options.question.join(' ')
        choices = options.choices.nil? ? nil : options.choices.join(' ')
        # TODO: handle type
        command = CommandLogic::Poll.new(event, question, choices, options.duration, options.multi, nil)
        response = command.run

        message = event.respond(response[:content], false, nil, nil, nil, nil, response[:components])
        TohsakaBot.poll_cache.create(
          message.id,
          message.channel.id,
          response[:content],
          response[:poll_data][:choices],
          response[:poll_data][:duration],
          response[:poll_data][:multi]
        )
        break
      end

      extend Discordrb::EventContainer
      command(:getsauce,
              aliases: %i[saucenao sauce rimg],
              description: 'Finds source for the posted image.',
              usage: 'sauce <link (or attachment)>') do |event, url|
        command = CommandLogic::GetSauce.new(event, url)
        response = command.run
        event.respond(response[:content], nil, response[:embeds].first)
      end

      command(:quickie,
              aliases: %i[qm],
              description: 'A quick message which is deleted after n seconds.',
              usage: 'quickie <message> <1-10 (seconds, integer, default 5)>',
              min_args: 1) do |event, *msg|
        duration = if !Integer(msg[-1], exception: false) || msg.is_a?(String)
                     5
                   else
                     msg.pop.to_i
                   end
        sleep(CommandLogic::Quickie.duration(duration))
        event.message.delete
      end
    end
  end
end
