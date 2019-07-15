module TohsakaBot
  module Commands
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:SEIBAA,
              aliases: %i[seibaa],
              description: 'Saber',
              usage: '',
              bucket: :saber,
              rate_limit_message: "Your command seals are on cooldown for %time%s!",
              rescue: "Something went wrong!\n`%exception%`") do |event|

        @sabers = ['img/saber/saber.gif', 'img/saber/saber2.gif', 'img/saber/saber_eating.gif', 'img/saber/saber_eating2.gif' ]
        rng_saber = @sabers.sample
        event.channel.send_file(File.open("#{rng_saber}"))
      end
    end
  end
end