# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Tester
      BOT.application_command(:tester).group(:txt) do |group|
        group.subcommand('upcase') do |event|
          event.respond(content: event.options['txt'].strip_mass_mentions.upcase)
        end
      end
    end
  end
end
