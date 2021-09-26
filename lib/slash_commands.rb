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
          sub.boolean('verbose', I18n.t(:'commands.general_param.verbose_output'), required: false)
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
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
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
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
        end

        cmd.subcommand('list', I18n.t(:'commands.reminder.list.description')) do |sub|
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
        end

        cmd.subcommand('details', I18n.t(:'commands.reminder.details.description')) do |sub|
          sub.integer('id', I18n.t(:'commands.reminder.details.param.id'), required: true)
          sub.boolean('verbose', I18n.t(:'commands.general_param.verbose_output'), required: false)
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
        end
      end
    end

    # Roles #
    def role
      BOT.servers.each do |server|
        roles = TohsakaBot.read_roles(server[1].id, ids_only: true)
        next if roles.blank?

        cmd.subcommand_group(:role, I18n.t(:'commands.roles.description'), server_id: server[1].id) do |group|
          group.subcommand('add', I18n.t(:'commands.roles.add.description')) do |sub|
            sub.role(
              'role',
              I18n.t(:'commands.roles.param.role'),
              required: true,
              choices: roles
            )
            sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
          end

          group.subcommand('del', I18n.t(:'commands.roles.del.description')) do |sub|
            sub.role(
              'role',
              I18n.t(:'commands.roles.param.role'),
              required: true,
              choices: roles
            )
            sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
          end
        end
      end
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
            sub.string('code', I18n.t(:'commands.tool.admin.eval.param.code'), required: true)
          end

          group.subcommand('edit_permissions', I18n.t(:'commands.tool.admin.edit_permissions.description')) do |sub|
            sub.user('user', I18n.t(:'commands.tool.admin.edit_permissions.param.user'), required: true)
            sub.string('level', I18n.t(:'commands.tool.admin.edit_permissions.param.level'), required: true)
          end

          cmd.subcommand(:emojilist, I18n.t(:'commands.tool.admin.emoji_list.description'))
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
            sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
          end
        end

        cmd.subcommand(:help, I18n.t(:'commands.tool.help.description')) do |sub|
          sub.string('command', I18n.t(:'commands.tool.help.param.command'), required: false)
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
        end

        ## Feature Requests ##
        cmd.subcommand_group(:feature, I18n.t(:'commands.tool.feature.description')) do |group|
          group.subcommand('request', I18n.t(:'commands.tool.feature.request.description')) do |sub|
            sub.string('description', I18n.t(:'commands.tool.feature.request.param.description'), required: true)
          end

          group.subcommand('find', I18n.t(:'commands.tool.feature.find.description')) do |sub|
            sub.string(
              'tag',
              I18n.t(:'commands.tool.feature.find.param.tag'),
              required: true,
              choices: { new: "new", indev: "indev", done: "done", wontdo: "wontdo", all: "all" }
            )
          end

          group.subcommand('tag', I18n.t(:'commands.tool.feature.tag.description')) do |sub|
            sub.string('id', I18n.t(:'commands.tool.feature.tag.param.id'), required: true)
            sub.string(
              'tag',
              I18n.t(:'commands.tool.feature.tag.param.tag'),
              required: false,
              choices: { new: "new", indev: "indev", done: "done", wontdo: "wontdo", all: "all" }
            )
          end
        end

        cmd.subcommand(:ping, I18n.t(:'commands.tool.ping.description'))
      end
    end

    # Trigger #
    def trigger
      puts "trigger"
    end

    # Utility #
    # noinspection NonAsciiCharacters
    def utility
      BOT.register_application_command(:utility, I18n.t(:'commands.utility.description')) do |cmd|
        cmd.subcommand(:poll, I18n.t(:'commands.utility.poll.description')) do |sub|
          sub.string('question', I18n.t(:'commands.utility.poll.param.question'), required: true)
          sub.string('choices',  I18n.t(:'commands.utility.poll.param.choices'), required: true)
          sub.string('duration', I18n.t(:'commands.utility.poll.param.duration'), required: false)
          sub.string(
            'template',
            I18n.t(:'commands.utility.poll.param.template'),
            required: false,
            choices: { '👍👎': 'thumb', '✅❌': 'tick', '123': 'numbers' }
          )
          sub.boolean('multi', I18n.t(:'commands.utility.poll.param.multi'), required: false)
          sub.string(
            'type',
            I18n.t(:'commands.utility.poll.param.type'),
            required: false,
            choices: { button: 'button', emoji: 'emoji', dropdown: 'dropdown' }
          )
        end

        cmd.subcommand(:rollprobability, I18n.t(:'commands.utility.roll_probability.description')) do |sub|
          sub.string('chance', I18n.t(:'commands.utility.roll_probability.param.chance'), required: true)
          sub.integer('rolls', I18n.t(:'commands.utility.roll_probability.param.rolls'), required: true)
          sub.integer('hits', I18n.t(:'commands.utility.roll_probability.param.hits'), required: false)
        end

        cmd.subcommand(:getsauce, I18n.t(:'commands.utility.get_sauce.description')) do |sub|
          sub.string('link', I18n.t(:'commands.utility.get_sauce.param.link'), required: true)
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
        end

        cmd.subcommand(:quickie, I18n.t(:'commands.utility.quickie.description')) do |sub|
          sub.string('message', I18n.t(:'commands.utility.quickie.param.message'), required: true)
          sub.string('duration', I18n.t(:'commands.utility.quickie.param.duration'), required: false)
        end

        cmd.subcommand(:encode_message, I18n.t(:'commands.utility.encode_message.description')) do |sub|
          sub.string('message', I18n.t(:'commands.utility.encode_message.param.message'), required: true)
          sub.string(
            'algorithm',
            I18n.t(:'commands.utility.encode_message.param.algorithm'),
            required: false,
            choices: { rot13: 'rot13', base64: 'base64' }
          )
          sub.boolean('ephemeral', I18n.t(:'commands.general_param.ephemeral_false'), required: false)
        end

        ## Drink ##
        cmd.subcommand_group(:drink, I18n.t(:'commands.utility.drink.description')) do |group|
          group.subcommand('alko', I18n.t(:'commands.utility.drink.alko.description')) do |sub|
            sub.integer('budget', I18n.t(:'commands.utility.drink.alko.param.budget'), required: true)
            sub.string('type', I18n.t(:'commands.utility.drink.alko.param.type'), required: true)
          end

          group.subcommand('alkolist', I18n.t(:'commands.utility.drink.alkolist.description'))
        end
      end
    end
  end
end
