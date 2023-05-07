# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Tool
      extend Discordrb::Commands::CommandContainer

      command(:ping,
              description: I18n.t(:'commands.tool.ping.description'),
              usage: I18n.t(:'commands.tool.ping.usage')) do |event|
        m = event.respond(I18n.t(:'commands.tool.ping.response'))
        m.edit(I18n.t(
          :'commands.tool.ping.edited_response',
          locale: TohsakaBot.get_locale(event.user.id),
          time: ((m.timestamp - event.timestamp) * 1000).truncate
        ))
      end

      command(:info,
              aliases: %i[information],
              description: 'Basic information about the bot.',
              usage: '') do |event|
        event.channel.send_embed do |embed|
          embed.title = 'INFO'
          embed.colour = 0xA82727
          embed.url = ''
          embed.description = ''
          embed.timestamp = TohsakaBot.time_now

          embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://cdn.discordapp.com/attachments/351170098754486289/648936828212215812/22_1602-4fe170.gif')
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'Rin', icon_url: 'https://cdn.discordapp.com/attachments/351170098754486289/648936891890008120/22_1615-a1fef0.png')
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Made with Ruby', icon_url: 'https://cdn.discordapp.com/emojis/232899886419410945.png')

          embed.add_field(name: 'Created by', value: 'Kohana#3717')
          embed.add_field(name: 'Source code', value: '[GitHub](https://github.com/CrescentKohana/TohsakaBot)')
        end
      end

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
