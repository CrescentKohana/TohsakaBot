# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Japanese
      extend Discordrb::Commands::CommandContainer

      command(:pitch,
              aliases: TohsakaBot.get_command_aliases('commands.japanese.pitch.aliases'),
              description: I18n.t(:'commands.japanese.pitch.description'),
              usage: I18n.t(:'commands.japanese.pitch.usage'),
              min_args: 1) do |event, word|
        command = CommandLogic::Pitch.new(event, word)
        response = command.run
        event.respond(response[:content], nil, response[:embeds].first)
      end
    end
  end
end
