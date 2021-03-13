# frozen_string_literal: true

module TohsakaBot
  module Async
    module URLCleaner
      # Removes three days old links from repost db.
      Thread.new do
        loop do
          db = YAML.load_file('data/repost.yml')
          time_now = Time.now.to_i

          unless db.nil? || db == false
            db.each do |k, v|
              next unless time_now >= v['time'].to_i + (72 * 60 * 60)

              rstore = YAML::Store.new('data/repost.yml')
              rstore.transaction do
                rstore.delete(k)
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
