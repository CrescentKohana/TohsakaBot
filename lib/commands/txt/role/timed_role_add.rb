# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TimedRoleAdd
      extend Discordrb::Commands::CommandContainer
      command(:addtimedrole,
              aliases: TohsakaBot.get_command_aliases('commands.roles.timed_role.aliases'),
              description: I18n.t(:'commands.roles.timed_role.add.description'),
              usage: I18n.t(:'commands.roles.timed_role.add.usage'),
              enabled_in_pm: false,
              min_args: 1) do |event, *msg|
        options = TohsakaBot.command_parser(
          event, msg,
          I18n.t(:'commands.roles.timed_role.add.help.banner'),
          I18n.t(:'commands.roles.timed_role.add.help.extra_help'),
          [:roles, I18n.t(:'commands.roles.timed_role.add.help.roles'), { type: :strings }],
          [:times, I18n.t(:'commands.roles.timed_role.add.help.times'), { type: :strings }],
          [:mode, I18n.t(:'commands.roles.timed_role.add.help.mode'), { type: :string }]
        )
        break if options.nil?

        if options.roles.nil?
          event.respond(I18n.t(:'commands.roles.timed_role.errors.no_roles_given'))
          break
        end

        if options.times.nil?
          event.respond(I18n.t(:'commands.roles.timed_role.errors.no_time_given'))
          break
        end

        begin
          entry = RoleController.parse_timed_role(event, options.roles, options.times, options.mode)
        rescue RoleHandler::RoleNotFound, RoleHandler::DayParseError, RoleHandler::TimeParseError => e
          event.respond e.message
          break
        end

        id = RoleController.store_timed_role(entry)
        times = entry[:times].map { |time| "`#{time[:day]}-#{time[:start]}-#{time[:end]}`" }.join(' ')
        roles = entry[:roles].map { |role| "`#{role}`" }.join(' ')
        event.respond(
          I18n.t(
            :'commands.roles.timed_role.add.response',
            id: id,
            roles: roles,
            times: times,
            mode: entry[:mode]
          )
        )
      end
    end
  end
end
