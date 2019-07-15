module TohsakaBot
  module Async
    module RepostCheck

      # Removes three days old links from repost db.
      Thread.new do

        loop do
          repostdb = YAML.load_file('data/repost.yml')
          timen = Time.now.to_i
          repostdb.each do |key, value|

            if timen >= value["time"].to_i + 72*60*60
              rstore = YAML::Store.new('data/repost.yml')
              rstore.transaction do
                rstore.delete(key)
                rstore.commit
              end
            end
          end
          sleep(3600)
        end
      end
    end
  end
end
