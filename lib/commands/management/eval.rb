# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Eval
      extend Discordrb::Commands::CommandContainer
      command(:eval,
              description: 'Run Ruby code. Only for the owner.',
              help_available: false,
              permission_level: 1000) do |event|
        # Hard coded to allow ONLY the owner to have access.
        break unless event.user.id == AUTH.owner_id.to_i

        code = event.message.content[5..]
        begin
          eval code
        rescue StandardError => e
          "An error occurred 😞 ```#{e}```"
        end
      end
    end
  end
end
