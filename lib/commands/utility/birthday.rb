module TohsakaBot
  module Commands
    module Birthday
      extend Discordrb::Commands::CommandContainer
      command(:birthday,
              aliases: %i[birthday addbirthday updatebirthday bd],
              description: 'Saves your birthday so that I can congratulate you!',
              min_args: 3,
              usage: 'birthday <year> <month> <day>',
              rescue: "Something went wrong!\n`%exception%`") do |event, year, month, day|


      end
    end
  end
end
