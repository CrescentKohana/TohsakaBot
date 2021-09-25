# frozen_string_literal: true

module TohsakaBot
  module Slash
    module Admin
      BOT.application_command(:tool).group(:admin) do |group|
        group.subcommand('registerslash') do |event|
          command = CommandLogic::RegisterSlash.new(event, event.options['types'])
          respond = command.run
          event.respond(content: respond[:content]) unless respond.nil?
        end

        group.subcommand('eval') do |event|
          command = CommandLogic::Eval.new(event, event.options['code'])
          respond = command.run
          event.respond(content: respond[:content]) unless respond.nil?
        end

        group.subcommand('editpermissions') do |event|
          command = CommandLogic::EditPermissions.new(event, event.options['user'], event.options['level'])
          respond = command.run
          event.respond(content: respond[:content], allowed_mentions: false) unless respond.nil?
        end
      end
    end
  end
end
