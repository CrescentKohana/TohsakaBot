module TohsakaBot
  module Commands
    module Eval
      extend Discordrb::Commands::CommandContainer
      command(:eval,
              aliases: %i[breakstuff],
              description: 'Run code. Only for the owner.',
              help_available: false) do |event, *code|

        # Hard coded to allow ONLY the owner to have access.
        break unless event.user.id == AUTH.owner_id.to_i
        begin
          eval code.join(' ')
        rescue => e
          "An error occurred 😞 ```#{e}```"
        end
      end
    end
  end
end
