# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Japanese
      BOT.application_command(:japanese).subcommand('pitch') do |event|
        command = CommandLogic::Pitch.new(event, event.options['word'])
        response = command.run
        event.respond(content: response[:content], embeds: response[:embeds])
      end
    end
  end
end
