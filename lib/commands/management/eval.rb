module TohsakaBot
  module Commands
    module Eval
      extend Discordrb::Commands::CommandContainer
      command(:eval,
              aliases: %i[breakstuff],
              description: 'DANGER | 危険です。',
              help_available: false,
              rescue: "Something went wrong!\n`%exception%`") do |event, *code|

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
