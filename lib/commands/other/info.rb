module TohsakaBot
  module Commands
    module Information
      extend Discordrb::Commands::CommandContainer
      command(:info,
              aliases: %i[information],
              description: 'Basic information about the bot.',
              usage: '',
              rescue: "Something went wrong!\n`%exception%`") do |event|

        event.channel.send_file(File.open("img/rin/rin_blush.gif"))
        event.<< "A Discord bot created by Luukuton#8888 with Ruby."
      end
    end
  end
end