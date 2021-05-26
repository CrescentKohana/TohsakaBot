# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Reminder
      BOT.application_command(:reminder).subcommand('add') do |event|
        if TohsakaBot.registered?(event.user.id)
          command = CommandLogic::ReminderAdd.new(event,
                                                  event.options['when'],
                                                  event.options['msg'],
                                                  event.options['repeat_interval'])
          response = command.run

          reply = event.respond(content: response[:content], embeds: response[:embeds], wait: true)
          Discordrb::API::Channel.create_reaction("Bot #{AUTH.bot_token}", reply.channel_id, reply.id, '🔔')
        else
          event.respond(content: I18n.t("errors.not_registered"))
        end
      end

      BOT.application_command(:reminder).subcommand('del') do |event|
        if TohsakaBot.registered?(event.user.id)
          command = CommandLogic::ReminderDel.new(event, event.options['ids'].split(" "))
          event.respond(content: command.run[:content])
        else
          event.respond(content: I18n.t("errors.not_registered"))
        end
      end

      BOT.application_command(:reminder).subcommand('mod') do |event|
        if TohsakaBot.registered?(event.user.id)
          command = CommandLogic::ReminderMod.new(event,
                                                  event.options['id'],
                                                  event.options['when'],
                                                  event.options['msg'],
                                                  event.options['repeat'],
                                                  event.options['channel'])
          response = command.run
          reply = event.respond(content: response[:content], wait: true)
          Discordrb::API::Channel.create_reaction("Bot #{AUTH.bot_token}", reply.channel_id, reply.id, '🔔')
        else
          event.respond(content: I18n.t("errors.not_registered"))
        end
      end

      BOT.application_command(:reminder).subcommand('details') do |event|
        if TohsakaBot.registered?(event.user.id)
          command = CommandLogic::ReminderDetails.new(event, event.options['id'], event.options['verbose'])
          response = command.run
          event.respond(content: response[:content], embeds: response[:embeds], ephemeral: event.options['ephemeral'])
        else
          event.respond(content: I18n.t("errors.not_registered"), ephemeral: event.options['ephemeral'])
        end
      end

      BOT.application_command(:reminder).subcommand('list') do |event|
        if TohsakaBot.registered?(event.user.id)
          command = CommandLogic::ReminderList.new(event)
          event.respond(content: command.run[:content], ephemeral: event.options['ephemeral'])
        else
          event.respond(content: I18n.t("errors.not_registered"), ephemeral: event.options['ephemeral'])
        end
      end
    end
  end
end
