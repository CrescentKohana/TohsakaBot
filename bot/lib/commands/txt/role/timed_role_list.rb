# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TimedRoleList
      extend Discordrb::Commands::CommandContainer
      command(:timedrolelist,
              aliases: TohsakaBot.get_command_aliases('commands.roles.timed_role.list.aliases'),
              description: I18n.t(:'commands.roles.timed_role.list.description'),
              usage: I18n.t(:'commands.roles.timed_role.list.usage')) do |event|
        result_amount = 0
        header = "`  ID | MODE     | TIMES` **for** `ROLES                  `\n".dup
        output = ''.dup

        timed_roles = YAML.load_file('data/timed_roles.yml')
        timed_roles.each do |id, timed_role|
          result_amount += 1
          times = timed_role[:times].map { |time| "`#{time[:day]}-#{time[:start]}-#{time[:end]}`" }.join(' ')
          roles = timed_role[:roles].map { |role| "`#{role}`" }.join(' ')

          output << "`#{format('%4s', id)} | #{format('%-8s', timed_role[:mode])} |` #{times} **for** #{roles}\n"
        end

        where = result_amount > 5 ? event.author.pm : event.channel
        msgs = []
        if result_amount.positive?
          header << output
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(header), where)
        else
          msgs << event.respond('No timed roles found.')
        end

        TohsakaBot.expire_msg(where, msgs, event.message)
        break
      end
    end
  end
end
