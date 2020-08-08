module TohsakaBot
  module Commands
    module RegardsKELA
      extend Discordrb::Commands::CommandContainer
      command(:regardskela,
              aliases: %i[kela],
              description: 'Kindly regards Kela.',
              usage: 'kela <message>',
              min_args: 1) do |event, *msg|

        require 'mini_magick'

        #image = MiniMagick::Image.open("img/kela.png")
        #image.resize "100x100"
        #image.format "png"
        #image.write "img/kela_output.png"


        # TODO: I'm not sure what to do with this. It's supposed to add a text to the image
        # but I cannot get the right font size no matter what.
        MiniMagick::Tool::Convert.new do |convert|
          convert << "img/kela.png"
          convert.draw 'text 22,90 "' + msg.join(' ') + '"' #"-annotate" << "0 paska" ##{msg.join(' ')}
          convert.font '-*-helvetica-*-r-*-*-80-*-*-*-*-*-*-2'
          convert << "img/kela_output.png"
        end

        event.channel.send_file(File.open('img/kela_output.png', "r"))
        File.delete('img/kela_output.png')
      end
    end
  end
end
