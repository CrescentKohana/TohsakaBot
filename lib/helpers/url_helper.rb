module TohsakaBot
  module URLHelper
    def url_regex(capture_group = false)
      if capture_group
        %r{(?<capture>(?:(?:https?|ftp):\/\/)
         (?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})
         (?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})
         (?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])
         (?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
         (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
         (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|
         (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)
         (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*
         (?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?)}ix
      else
        %r{.*((?:(?:https?|ftp):\/\/)
         (?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})
         (?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})
         (?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])
         (?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
         (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
         (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|
         (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)
         (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*
         (?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?).*}ix
      end
    end

    def url_parse(url)
      parsed = URI.parse(url)

      return nil if parsed.host.nil?

      domain = PublicSuffix.domain(parsed.host)
      subdomain = PublicSuffix.parse(parsed.host).trd
      path = parsed.path

      query = parsed.query
      return nil if query.nil? && path.nil?
      parameters = query.nil? ?  nil : CGI.parse(query)

      case domain
      when "youtube.com"
        return nil if parameters.nil?
        youtube_id = parameters['v']
        return nil if youtube_id.nil?
        type = "youtube"
        url_result = parameters['v'][0]
      when "youtu.be"
        return nil if path.nil?
        youtube_id = path.match(/\/(\S{11})(\/|)/i).captures
        return nil if youtube_id.nil?
        type = "youtube"
        url_result = youtube_id[0]
      when "twitter.com"
        return nil if path.nil?
        twitter_id = path.match(/\/\S*\/status\/(\d*)/i).captures
        return nil if twitter_id.nil?
        type = "twitter"
        url_result = twitter_id[0]
      when "reddit.com", "redd.it"
        return nil if path.nil?
        if subdomain == 'i'
          reddit_id = path.match(/\/(\w{13}).\S*/i).captures
        else
          reddit_id = path.match(/\/r\/\S*\/comments\/(\S{6})(\/\S*|)/i).captures
        end
        return nil if reddit_id.nil?
        type = "reddit"
        url_result = reddit_id[0]
      when "twitch.tv"
        return nil unless subdomain == "clips"
        twitch_clips_id = path.match(/\/(.*)/i).captures
        return nil if twitch_clips_id.nil?
        type = "twitch"
        url_result = twitch_clips_id[0]
      else
        # Just the URL, no parsing
        type = 'url'
        url_result = url
      end

      [type, url_result]
    end

    def url_match(event)
      urls = URI.extract(strip_markdown(event.message.content))
      db = YAML.load_file('data/repost.yml')

      if !urls.nil? && db
        urls.each do |url|
          type, url_result = TohsakaBot.url_parse(url)
          next if type.nil?
          db.each do |k, v|
            next if v['user'].to_i == event.author.id.to_i
            return v['time'].to_i, v['user'].to_i, v['msg_uri'] if v['url'] == url_result && v['type'] == type
          end
        end
        nil
      end
    end
  end

  TohsakaBot.extend URLHelper
end
