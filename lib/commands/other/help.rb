module TohsakaBot
  module Commands
    module Help
      extend Discordrb::Commands::CommandContainer
      command(:help,
              aliases: %i[sendhelp],
              description: 'Returns a list of all commands, or help for a specific command.',
              usage: 'help <command name>') do |event, command_name|

        if command_name
          command = BOT.commands[command_name.to_sym]
          if command.is_a?(Discordrb::Commands::CommandAlias)
            command = command.aliased_command
            command_name = command.name
          end

          unless command
            event.respond "The command `#{command_name}` does not exist."
            break
          end

          desc = command.attributes[:description] || ''
          usage = command.attributes[:usage]
          parameters = command.attributes[:parameters]

          result = "**`#{command_name}`**: #{desc}"

          result += "\nUsage: `#{usage}`" if usage

          if parameters
            result += "\nParameters:\n```"
            parameters.each { |p| result += "\n#{p}" }
            result += '```'
          end

          aliases = BOT.command_aliases(command_name.to_sym)
          unless aliases.empty?
            result += "\nAliases: "
            result += aliases.map { |a| "`#{a.name}`" }.join(', ')
          end

          result
        else
          available_commands = BOT.commands.values.reject do |c|
            c.is_a?(Discordrb::Commands::CommandAlias) || !c.attributes[:help_available]
          end

          "Help for a specific command: `help <command name>`\n**List of commands:**\n" +
              (available_commands.reduce '' do |memo, c|
                memo + "`#{c.name}`, "
              end)[0..-3]
        end
      end
    end
  end
end
