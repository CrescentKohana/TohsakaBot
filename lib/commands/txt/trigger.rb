# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Trigger
      extend Discordrb::Commands::CommandContainer

      command(:triggerstats,
              aliases: TohsakaBot.get_command_aliases('commands.trigger.stats.aliases'),
              description: I18n.t(:'commands.trigger.stats.description'),
              usage: I18n.t(:'commands.trigger.stats.usage'),
              require_register: true) do |event, *input|
        options = TohsakaBot.command_parser(
          event, input,
          I18n.t(:'commands.trigger.stats.help.banner'),
          I18n.t(:'commands.trigger.stats.help.extra_help'),
          [:sorting, I18n.t(:'commands.trigger.stats.help.sorting'), { type: :boolean }],
          [:mode, I18n.t(:'commands.trigger.stats.help.mode'), { type: :strings }],
          [:chance, I18n.t(:'commands.trigger.stats.help.chance'), { type: :boolean }],
          [:type, I18n.t(:'commands.trigger.stats.help.type'), { type: :boolean }]
        )
        break if options.nil?

        command = CommandLogic::TriggerStats.new(event, options.sorting, options.mode, options.chance, options.type)
        response = command.run

        event.respond(response[:content])
      end
    end
  end
end
