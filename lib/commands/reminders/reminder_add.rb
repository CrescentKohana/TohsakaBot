# frozen_string_literal: true

module TohsakaBot
  module Commands
    module ReminderAdd
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.add.aliases'),
              description: I18n.t(:'commands.reminder.add.description'),
              usage: I18n.t(:'commands.reminder.add.usage'),
              min_args: 1,
              require_register: true) do |event, *msg|
        options = TohsakaBot.command_parser(
          event, msg,
          I18n.t(:'commands.reminder.add.help.banner'),
          I18n.t(:'commands.reminder.add.help.extra_help'),
          [:datetime, I18n.t(:'commands.reminder.add.help.datetime'), { type: :strings }],
          [:msg, I18n.t(:'commands.reminder.add.help.msg'), { type: :strings }],
          [:repeat, I18n.t(:'commands.reminder.add.help.repeat'), { type: :strings }]
        )
        break if options.nil?

        legacy = false
        datetime = options.datetime
        message = options.msg.nil? ? nil : options.msg.join(' ')
        repeat = options.repeat.nil? ? nil : options.repeat.join(' ')

        if datetime.blank? && (!options.msg.blank? || !options.repeat.blank?)
          event.respond I18n.t(:'commands.reminder.add.errors.all_blank')
          break
        elsif datetime.blank? && !msg.nil?
          msg = msg.join(' ')
          datetime = if msg.include? ';'
                       msg.split(';', 2)
                     elsif msg.include? ' '
                       msg.split(' ', 2)
                     else
                       [msg, '']
                     end
          legacy = true
        end

        datetime = datetime.join(' ') unless legacy

        rem = ReminderController.new(event, nil, legacy, datetime, message, repeat, event.channel.id)

        begin
          ReminderHandler.handle_user_limit(event.message.user.id.to_i)
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

        rem.store_reminder
      end
    end
  end
end
