module TohsakaBot
  module Commands
    module Reboot
      extend Discordrb::Commands::CommandContainer
      command(:reboot,
              aliases: %i[restart kill],
              description: 'Reboots the bot.',
              usage: "Don't use",
              required_permissions: %i[manage_server],
              rescue: "Something went wrong!\n`%exception%`") do |event|

        #line = Terrapin::CommandLine.new("/home/luuq/discord-bots/TohsakaBot/runbot.sh")
        #line.run
        #bundle exec ruby run.rb

        pid = spawn("/home/luuq/discord-bots/TohsakaBot/runbot.sh")
        Process.detach(pid)

        event.respond("Rebooting...")
        BOT.stop
      end
    end
  end
end