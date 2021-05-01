# frozen_string_literal: true

module TohsakaBot
  module URLHelper
    def url_regex(capture_group: false)
      if capture_group
        %r{(?<capture>(?:(?:https?|ftp)://)
         (?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})
         (?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})
         (?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])
         (?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
         (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
         (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|
         (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)
         (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*
         (?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:/[^\s]*)?)}ixm
      else
        %r{.*((?:(?:https?|ftp)://)
         (?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})
         (?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})
         (?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])
         (?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
         (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
         (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|
         (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)
         (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*
         (?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:/[^\s]*)?).*}ixm
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

      parameters = query.nil? ? nil : CGI.parse(query)

      case domain
      when PublicSuffix.domain(CFG.web_url)
        return nil
      when 'youtube.com'
        return nil if parameters.nil?

        youtube_id = parameters['v']
        return nil if youtube_id.nil?

        category = 'youtube'
        url_result = parameters['v'][0]
      when 'youtu.be'
        return nil if path.nil?

        youtube_id = path.match(%r{/(\S{11})(/|)}i).captures
        return nil if youtube_id.nil?

        category = 'youtube'
        url_result = youtube_id[0]
      when 'twitter.com'
        return nil if path.nil?

        twitter_id = path.match(%r{/\S*/status/(\d*)}i).captures
        return nil if twitter_id.nil?

        category = 'twitter'
        url_result = twitter_id[0]
      when 'reddit.com', 'redd.it'
        return nil if path.nil?

        reddit_id = if subdomain == 'i'
                      path.match(%r{/(\w{13}).\S*}i).captures
                    else
                      path.match(%r{/r/\S*/comments/(\S{6})(/\S*|)}i).captures
                    end

        return nil if reddit_id.nil?

        category = 'reddit'
        url_result = reddit_id[0]
      when 'twitch.tv'
        return nil unless subdomain == 'clips'

        twitch_clips_id = path.match(%r{/(.*)}i).captures
        return nil if twitch_clips_id.nil?

        category = 'twitch'
        url_result = twitch_clips_id[0]
      else
        # Just the URL, no parsing
        category = 'url'
        url_result = url
      end

      [category, url_result]
    end

    def url_match(event)
      urls = URI.extract(strip_markdown(event.message.content))
      db = TohsakaBot.db[:linkeds]

      return unless !urls.nil? && db

      urls.each do |url|
        category, url_result = TohsakaBot.url_parse(url)
        next if category.nil?

        return db.where(category: category, url: url_result).exclude(author_id: event.author.id.to_i).single_record
      end
      nil
    end
  end

  TohsakaBot.extend URLHelper
end
