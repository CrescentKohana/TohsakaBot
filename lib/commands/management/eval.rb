module TohsakaBot
  module Commands
    module Eval
      extend Discordrb::Commands::CommandContainer
      command(:eval,
              aliases: %i[breakstuff],
              description: 'CEASE',
              help_available: false,
              allowed_roles: [299992716480348160],
              rescue: "Something went wrong!\n`%exception%`") do |event, *code|

        break unless event.user.id == $config['owner_id'].to_i
        begin
          eval code.join(' ')
        rescue => e
          "An error occurred 😞 ```#{e}```"
        end
      end
    end
  end
end
