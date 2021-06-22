# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Reminder
      extend Discordrb::Commands::CommandContainer

      command(:remindme,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.add.aliases'),
              description: I18n.t(:'commands.reminder.add.description'),
              usage: I18n.t(:'commands.reminder.add.usage'),
              min_args: 1,
              require_register: true) do |event, *input|
        options = TohsakaBot.command_parser(
          event, input,
          I18n.t(:'commands.reminder.add.help.banner'),
          I18n.t(:'commands.reminder.add.help.extra_help'),
          [:datetime, I18n.t(:'commands.reminder.add.help.datetime'), { type: :strings }],
          [:msg, I18n.t(:'commands.reminder.add.help.msg'), { type: :strings }],
          [:repeat, I18n.t(:'commands.reminder.add.help.repeat'), { type: :strings }]
        )
        break if options.nil?

        msg = options.msg.nil? ? nil : options.msg.join(' ')
        repeat = options.repeat.nil? ? nil : options.repeat.join(' ')
        command = CommandLogic::ReminderAdd.new(event, options.datetime, msg, repeat, input)
        response = command.run

        if event.channel.pm? || response[:error]
          event.respond(response[:content])
        else
          # with subscribe (copy reminder) button
          event.respond(response[:content], false, nil, nil, nil, nil, response[:components])
          event.message.delete
        end
      end


      command(:reminderdel,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.del.aliases'),
              description: I18n.t(:'commands.reminder.del.description'),
              usage: I18n.t(:'commands.reminder.del.usage'),
              min_args: 1,
              require_register: true) do |event, *ids|
        command = CommandLogic::ReminderDel.new(event, ids)
        event.respond(command.run[:content])
      end


      command(:remindermod,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.mod.aliases'),
              description: I18n.t(:'commands.reminder.mod.description'),
              usage: I18n.t(:'commands.reminder.mod.usage'),
              min_args: 1,
              require_register: true) do |event, *message|
        options = TohsakaBot.command_parser(
          event, message, I18n.t(:'commands.reminder.mod.help.banner'), '',
          [:id, I18n.t(:'commands.reminder.mod.help.id'), { type: :string }],
          [:datetime, I18n.t(:'commands.reminder.mod.help.datetime'), { type: :strings }],
          [:msg, I18n.t(:'commands.reminder.mod.help.msg'), { type: :strings }],
          [:repeat, I18n.t(:'commands.reminder.mod.help.repeat'), { type: :strings }],
          [:channel, I18n.t(:'commands.reminder.mod.help.channel'), { type: :string }]
        )
        break if options.nil?

        command = CommandLogic::ReminderMod.new(event,
                                                options.id,
                                                options.datetime&.join(' '),
                                                options.msg&.join(' '),
                                                options.repeat&.join(' '),
                                                options.channel&.first)
        event.respond(command.run[:content])
      end


      command(:reminderdetails,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.details.aliases'),
              description: I18n.t(:'commands.reminder.details.description'),
              usage: I18n.t(:'commands.reminder.details.usage'),
              min_args: 1,
              require_register: true) do |event, id, verbose|
        command = CommandLogic::ReminderDetails.new(event, id, verbose)
        event.respond(nil, nil, command.run[:embeds].first)
      end


      command(:reminders,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.list.aliases'),
              description: I18n.t(:'commands.reminder.list.description'),
              usage: I18n.t(:'commands.reminder.list.usage'),
              require_register: true) do |event|
        command = CommandLogic::ReminderList.new(event)
        msgs = []
        msgs << event.respond(command.run[:content])
        TohsakaBot.expire_msg(event.channel, msgs, event.message)
      end
    end
  end
end
