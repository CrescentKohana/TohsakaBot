# frozen_string_literal: true

module TohsakaBot
  module Commands
    module ReminderMod
      extend Discordrb::Commands::CommandContainer
      command(:remindermod,
              aliases: %i[modreminder remindermodify modifyreminder modremind remindmod mr modrem remmod editreminder editrem remedit reminderedit],
              description: 'Edits a reminder.',
              usage: "Use 'remindermod -h|--help' for help.",
              min_args: 1,
              require_register: true) do |event, *message|
        discord_uid = event.author.id.to_i

        options = TohsakaBot.command_parser(
          event, message, 'Usage: remindermod [-i id] [-d datetime] [-m message] [-r repeat]', '',
          [:id, 'Reminder id to edit', { type: :string }],
          [:datetime, 'Edit the time when to remind. Format: yMwdhms OR yyyy/MM/dd hh.mm.ss OR natural language', { type: :strings }],
          [:msg, 'Edit the message.', { type: :strings }],
          [:repeat, 'Edit the interval duration for repeated reminders. Format: dhm (eg. 2d6h20m)', { type: :strings }],
          [:channel, 'Edit the channel where you will be reminded. Format: channel id', { type: :string }]
        )
        break if options.nil?

        if options.datetime.nil? && options.msg.nil? && options.repeat.nil?
          event.respond('Specify an action')
          break
        elsif options.id.nil?
          event.respond('Specify a reminder ID to edit')
          break
        end

        reminders = TohsakaBot.db[:reminders]
        reminder = reminders.where(id: options.id.to_i).single_record!

        if reminder.nil?
          event.respond('Could not find reminder with that ID')
          break
        elsif reminder[:user_id] != TohsakaBot.get_user_id(discord_uid)
          event.respond('No permissions to edit this reminder')
          break
        end

        datetime = options.datetime.nil? ? nil : options.datetime.join(' ')
        message = options.msg.nil? ? nil : options.msg.join(' ')
        repeat = options.repeat.nil? ? nil : options.repeat.join(' ')

        authorized_channels = TohsakaBot.allowed_channels(discord_uid).map(&:id)
        channel = options.channel.nil? || !authorized_channels.include?(options.channel.to_i) ? nil : options.channel.first

        rem = ReminderController.new(event, options.id, false, datetime, message, repeat, channel)
        discord_uid = event.message.user.id.to_i

        begin
          ReminderHandler.handle_user_limit(discord_uid)
        rescue ReminderHandler::UserLimitReachedError => e
          event.respond e.message
          break
        end

        begin
          rem.convert_datetime
        rescue ReminderHandler::DatetimeError, ReminderHandler::RepeatIntervalError => e
          event.respond e.message
          break
        end

        rem.update_reminder
      end
    end
  end
end
