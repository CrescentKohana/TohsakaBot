module TohsakaBot
  module Commands
    module Stars
      extend Discordrb::Commands::CommandContainer
      command(:stars,
              aliases: %i[star],
              description: '*',
              usage: 'curse <user (optional)> <msg>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, u, *msg|

        # Not sure why. For memes?
        if u.start_with? /<@!\d*>/
          user_obj = event.message.mentions
          member_obj = BOT.member(event.server, user_obj[0].id).display_name
        else
          member_obj = u
        end

        ch_msg = msg.join(' ').strip_mass_mentions.sanitize_string
        event.<< ".　　　　　　　　　　　　　.　　　　　.　　　　　    　　.
　.　　　　　 　　　　　　　　　　　　　　.　　　　　　　　　　 ✦ 　　　　   　
　　　˚　　　　　　　　　　　　　　*　　　　　　 
 　　　　　　　　　　　　　　　.　　　　　　　　　　　　　　.
　　 　　　　　　　 ✦ 　　　　　　　　　　 　 ‍ ‍ ‍ ‍ 　　　　 　　　　　　　　　　　　,　　   　

.　　　　　　　　　　　　　.　　　ﾟ　  　　　.　　　　　　　　　　　　　.

　　　　　　,　　　　　　　.　　　　　　    　　　　
　　　　　　　　　　　　　　　　　　  
　　　　　　　　　　　　　　　　　　    　      　　　　　        　　　　*　　　　　　　　　.
　　　　　　　　　　.　　　　　　　　　　　　　.
　　　　　　　　　　　　　　　　       　   　　　　
　　　　　　　　　　　　　　　　       　   　　　　　　　　　　　　　　　　       　    ✦
　   　　　,　　　　　　　　　*　　     　  #{member_obj.strip_mass_mentions.sanitize_string} #{ch_msg}    　 　　,　　　 ‍ ‍ ‍ ‍ 　 　　　　　　　　　　.　　　　　 　
　　　.　　　　　　　　　　　　　 　           　　　　　　　　　　　　　　　　　　　˚　　　
　   　　　　,　　　　　　　　　　　       　    　　　　　　　　　　　　　　　　.　　　
 　　    　　　　　 　　　　　.　　　　　　　　　　　　　.　　　　　　　　　　　　　　　*
　　   　　　　　 ✦ 　　　　　　　         　        　　　　
　　 　　　　　　　 　　　　　.　　　　　　　　　　　　　　　　　　.　　　　　    　　.
　 　　　　　.　　　　　　　　　   　　　　　.　　　　　　　　　　　.　　　　　　　　　　   　

　˚　　　　　　　　　　　　　　　　　　　　　ﾟ　　　　　.　　　　　　　　　　　　　　　.
　　 　　　 ‍ ‍
‍ ‍ ‍ ‍ ‍ ‍ ‍ ‍ ‍ ‍ ,　 　　　　　　　　　　　　　　*　　　　　　　　　　　　　　　　　　　   　
　　　　
　　　　　　　　　　　　　˚　　　　　　　　　　　　　　　　 ✦ 　　　　　　　,　　　　　　
　   　　　　,　　　　　　　　　　　　　.　　　　　　　　　　　　　　 　　　　　　　　　."
      end
    end
  end
end