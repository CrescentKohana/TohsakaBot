module TohsakaBot
  module Events
    module TouhouCheck
      extend Discordrb::EventContainer
      # Check for Touhou tags in YouTube video. A joke in our Discord.
      message(content: [/.*https:\/\/www.youtu.*|.*https:\/\/youtu.*/]) do |event|

        rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
        rate_limiter.bucket :touh, delay: 10
        words = %w[東方 とうほう トウホウ touhou]

        next if rate_limiter.rate_limited?(:touh, event.channel)

        urls = URI.extract(event.message.content)
        i = 0
        @titles = []
        @descriptions = []

        until i == urls.count
          vid = if urls[0].include?('?v=')
                  CGI.parse(URI.parse(urls[i]).query)['v'][0]
                else
                  urls[0].split('/')[-1]
                end

          url = "https://www.googleapis.com/youtube/v3/videos?part=id%2C+snippet&id=#{vid}&key=#{$config['yt_apikey']}"
          parsed = JSON.parse(Net::HTTP.get(URI(url)))
          unless parsed.any? then break end

          @titles << parsed['items'][0]['snippet']['title']
          @descriptions << parsed['items'][0]['snippet']['description']
          i += 1
        end

        if words.any? { |word| @titles[0].downcase.include?(word) || @descriptions[0].downcase.include?(word) }

          sent_msg = event.channel.send_file(File.open('img/touhou.jpg'))
          remove_msg = event.message.await!(timeout: 15)

          if remove_msg.content == "tyhmä"
            sent_msg.delete
          end
        end
      end
    end
  end
end
