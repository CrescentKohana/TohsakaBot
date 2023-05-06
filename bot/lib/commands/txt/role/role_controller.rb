# frozen_string_literal: true

module TohsakaBot
  class RoleController
    include ActionView::Helpers::DateHelper
    TIME_REGEX = /^(2[0-3]|1[0-9]|0[0-9]):(60|[0-5][0-9])(:(60|[0-5][0-9])|)/.freeze

    def self.days(table: false)
      day_table = {
        0 => %w[weekend sun],
        1 => %w[weekday mon],
        2 => %w[weekday tue],
        3 => %w[weekday wed],
        4 => %w[weekday thu],
        5 => %w[weekday fri],
        6 => %w[weekend sat]
      }
      return day_table if table

      weekdays = Set.new
      weekend = Set.new
      day_table.each do |key, day|
        if [0, 6].include?(key)
          weekend.merge(day)
        else
          weekdays.merge(day)
        end
      end

      { weekday: weekdays, weekend: weekend }
    end

    def self.parse_timed_role(event, roles, times, active)
      added_roles = Set.new
      roles.each do |role|
        next if added_roles.include? role

        role_id = TohsakaBot.permissions.allowed_role(event.author.id, event.server.id, role)
        next if role_id.nil?

        added_roles.add(TohsakaBot.server_cache[event.server.id][:roles][role_id][:name])
      end

      raise RoleHandler::RoleNotFound if added_roles.empty?

      roles_with_rules = Set.new
      timed_roles = YAML.load_file(CFG.data_dir + '/timed_roles.yml', permitted_classes: [Time])
      timed_roles.each_value do |timed_role|
        timed_role[:roles].each { |role| roles_with_rules.add(role) }
      end

      raise RoleHandler::RuleForRoleExists unless (added_roles & roles_with_rules).empty?

      parsed_times = Set.new
      days = days(table: false)
      days = days[:weekday].merge days[:weekend]

      times.each do |time|
        parsed_time = time.split("-")
        raise RoleHandler::DayParseError unless days.include?(parsed_time[0])
        raise RoleHandler::TimeParseError unless TIME_REGEX.match(parsed_time[1]) && TIME_REGEX.match(parsed_time[2])

        parsed_times.add({ day: parsed_time[0], start: parsed_time[1], end: parsed_time[2] })
      end

      active = if active.nil? || active[0].downcase == "a"
                 "active"
               else
                 "inactive"
               end

      { user: event.user.id,
        server: event.server.id,
        roles: added_roles.to_a,
        times: parsed_times.to_a,
        mode: active,
        activate_on: Time.now }
    end

    def self.store_timed_role(entry)
      db = YAML::Store.new(CFG.data_dir + '/timed_roles.yml')
      id = 1
      db.transaction do
        id += 1 while db.root?(id)
        db[id] = entry
        db.commit
      end

      id
    end
  end
end
