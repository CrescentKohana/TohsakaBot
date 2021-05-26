# frozen_string_literal: true

module TohsakaBot
  class SlashCommands
    # Fun #
    def fun
      BOT.register_application_command(:fun, I18n.t(:'commands.fun.description')) do |cmd|
        cmd.subcommand('number', I18n.t(:'commands.fun.number.description')) do |sub|
          sub.integer('start', I18n.t(:'commands.fun.number.param.start'), required: false)
          sub.integer('end', I18n.t(:'commands.fun.number.param.end'), required: false)
        end

        cmd.subcommand('coinflip', I18n.t(:'commands.fun.coinflip.description')) do |sub|
          sub.integer('times', I18n.t(:'commands.fun.coinflip.param.times'), required: false)
        end

        cmd.subcommand('chaos', I18n.t(:'commands.fun.chaos.description')) do |sub|
          sub.string('txt', I18n.t(:'commands.fun.chaos.param.txt'), required: true)
        end

        cmd.subcommand('fgo', I18n.t(:'commands.fun.fgo.description')) do |sub|
          sub.string(
            'currency',
            I18n.t(:'commands.fun.fgo.param.currency'),
            required: false,
            choices: { sq: 'SQ', yen: 'JPY', dollar: 'USD', rolls: 'R' }
          )
          sub.integer('amount', I18n.t(:'commands.fun.fgo.param.amount'), required: false)
          sub.boolean('verbose', I18n.t(:'commands.fun.fgo.param.verbose'), required: false)
        end
      end
    end

    # Japanese #
    def japanese
      BOT.register_application_command(:japanese, I18n.t(:'commands.japanese.description')) do |cmd|
        cmd.subcommand('pitch', I18n.t(:'commands.japanese.pitch.description')) do |sub|
          sub.string('word', I18n.t(:'commands.japanese.pitch.param.word'), required: true)
        end
      end
    end


    # Reminder #
    def reminder
      BOT.register_application_command(:reminder, 'Reminders') do |cmd|
        cmd.subcommand('add', I18n.t(:'commands.reminder.add.description')) do |sub|
          sub.string('when', I18n.t(:'commands.reminder.add.help.datetime'), required: true)
          sub.string('msg', I18n.t(:'commands.reminder.add.help.msg'), required: false)
          sub.string('repeat_interval', I18n.t(:'commands.reminder.add.help.repeat'), required: false)
        end

        cmd.subcommand('del', I18n.t(:'commands.reminder.del.description')) do |sub|
          sub.string('ids', 'Reminder IDs', required: true)
        end

        cmd.subcommand('mod', I18n.t(:'commands.reminder.mod.description')) do |sub|
          sub.integer('id', I18n.t(:'commands.reminder.mod.help.id'), required: true)
          sub.string('when', I18n.t(:'commands.reminder.mod.help.datetime'), required: false)
          sub.string('msg', I18n.t(:'commands.reminder.mod.help.msg'), required: false)
          sub.string('repeat', I18n.t(:'commands.reminder.mod.help.repeat'), required: false)
          sub.channel('channel', I18n.t(:'commands.reminder.mod.help.channel'), required: false)
        end

        cmd.subcommand('list', I18n.t(:'commands.reminder.list.description')) do |sub|
          sub.boolean('ephemeral', 'Private response?', required: false)
        end

        cmd.subcommand('details', I18n.t(:'commands.reminder.details.description')) do |sub|
          sub.integer('id', 'Reminder ID', required: true)
          sub.boolean('verbose', 'Verbose output?', required: false)
          sub.boolean('ephemeral', 'Private response?', required: false)
        end
      end
    end

    # Role #
    def role
      puts "role"
    end

    # Tool #
    def tool
      ## Admin ##
      BOT.register_application_command(:tool, I18n.t(:'commands.tool.description')) do |cmd|
        cmd.subcommand_group(:admin, I18n.t(:'commands.tool.admin.description')) do |group|
          group.subcommand('registerslash', I18n.t(:'commands.tool.admin.register_slash.description')) do |sub|
            sub.string('types', I18n.t(:'commands.tool.admin.register_slash.param.types'), required: true)
          end

          group.subcommand('eval', I18n.t(:'commands.tool.admin.eval.description')) do |sub|
            sub.string('code', I18n.t(:'commands.tool.admin.eval.param.code'))
          end

          group.subcommand('edit_permissions', I18n.t(:'commands.tool.admin.edit_permissions.description')) do |sub|
            sub.user('user', I18n.t(:'commands.tool.admin.edit_permissions.param.user'), required: true)
            sub.string('level', I18n.t(:'commands.tool.admin.edit_permissions.param.level'), required: true)
          end
        end

        ## User ##
        cmd.subcommand_group(:user, I18n.t(:'commands.tool.user.description')) do |group|
          group.subcommand('register', I18n.t(:'commands.tool.user.register.description'))

          group.subcommand('set_lang', I18n.t(:'commands.tool.user.set_lang.description')) do |sub|
            sub.string(
              'lang',
              I18n.t(:'commands.tool.user.set_lang.param.lang'),
              required: true,
              choices: { english: 'en', japanese: 'ja', finnish: 'fi' }
            )
          end

          group.subcommand('info', I18n.t(:'commands.tool.user.info.description')) do |sub|
            sub.user('user', I18n.t(:'commands.tool.user.info.param.user'), required: false)
          end
        end
      end

      ## Feature Req ##
    end

    # Trigger #
    def trigger
      puts "trigger"
    end

    # Utility #
    def utility
      puts "utility"
      ## Drink ##
    end

    # Help #
    def help
      puts "help"
    end
  end
end
