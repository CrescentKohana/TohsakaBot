# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class SetBirthday
      def initialize(event, raw_date, raw_time)
        @event = event
        @error = false

        if !Integer(raw_date, exception: false).nil? && raw_date.to_i.zero?
          @date = nil
          @next_year = false
          return
        end

        date_parts = raw_date.split('-')&.map(&:to_i)
        date_parts = raw_date.split('/')&.map(&:to_i) if date_parts.nil? || date_parts.length < 3
        date_parts = raw_date.split('.')&.map(&:to_i) if date_parts.nil? || date_parts.length < 3
        if date_parts.length != 3
          @error = true
          return
        end

        time_parts = %w[08 00]
        unless raw_time.nil?
          tmp_time = raw_time.split(':')
          time_parts = tmp_time if tmp_time.length == 2
        end

        @user_id = TohsakaBot.get_user_id(user_id)
        @now = TohsakaBot.user_time_now(TohsakaBot.command_event_user_id(@event))

        date_parts.reverse! if date_parts[2] >= 1900 # Reverses for DD/MM/YYYY
        @date = Time.new(date_parts[0].clamp(1900, @now.year),
                         date_parts[1].clamp(1, 12),
                         date_parts[2].clamp(1, 31),
                         time_parts[0],
                         time_parts[1],
                         '00')

        @next_year = Time.at(@date).change(year: @now.year) < @now unless @date.nil?
        @error = @date.nil?
      end

      def run
        return { content: I18n.t(:'commands.tool.user.birthday.error.invalid_date') } if @error

        TohsakaBot.db.transaction do
          TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(@user_id)).update(
            birthday: @date.nil? ? nil : @date.to_s,
            last_congratulation: @next_year ? @now.year : 0
          )
        end

        return { content: I18n.t(:'commands.tool.user.birthday.clear') } if @date.nil?

        { content: I18n.t(:'commands.tool.user.birthday.response', date: @date.strftime("%Y/%m/%d %H:%M")) }
      end
    end
  end
end
