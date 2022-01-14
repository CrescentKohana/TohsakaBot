# frozen_string_literal: true

module TohsakaBot
  # Periodically running cron jobs
  module Cron
    include Jobs

    Thread.new do
      timer = 0
      loop do
        now = Time.now

        # Every 1 second:
        Jobs.remind_on_time(now)
        Jobs.expire_polls(now)
        Jobs.expire_timeouts(now)

        TohsakaBot.queue_cache.list.each do |k, v|
          TohsakaBot.queue_cache.send_msgs(k) if v[:time] <= Time.now.to_i || (v[:embed] && v[:msgs].size == 25)
        end

        # Every 4 seconds:
        Jobs.type_in_channels if (timer % 4).zero?

        # Every 10 seconds:
        if (timer % 10).zero?
          Jobs.birthday(now)
          Jobs.daily_neko(now) unless CFG.daily_neko.blank? || !CFG.daily_neko
        end

        # Every 60 seconds:
        Jobs.manage_roles(now) if (timer % 60).zero?

        # Every 30 minutes:
        if (timer % 1800).zero?
          cfg = YAML.load_file('cfg/config.yml')
          TohsakaBot.status(cfg["status"][0], cfg["status"][1])
        end

        # Every hour:
        if (timer % 3600).zero?
          # Cleans 3d old links and file hashes.
          TohsakaBot.db[:linkeds].where(Sequel[:timestamp] <= Time.now - (72 * 60 * 60)).delete
        end

        # Every 24 hours:
        Jobs.load_alko(now) if (timer % 86_400).zero?

        timer = timer >= 86_400 ? 0 : timer + 1
        sleep(1)
      end
    end
  end
end
