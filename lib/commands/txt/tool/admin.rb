# frozen_string_literal: true

module TohsakaBot
  module Commands
    module Admin
      require_relative '../../../events/highlight/highlight_core' # for convertpins
      extend Discordrb::Commands::CommandContainer

      command(:registerslash,
              aliases: TohsakaBot.get_command_aliases('commands.tool.admin.register_slash.aliases'),
              description: I18n.t(:'commands.tool.admin.register_slash.description'),
              usage: I18n.t(:'commands.tool.admin.register_slash.usage'),
              permission_level: TohsakaBot.permissions.roles["owner"],
              min_args: 1) do |event, *types|
        command = CommandLogic::RegisterSlash.new(event, types)
        event.respond(command.run[:content])
      end


      command(:eval,
              description: I18n.t(:'commands.tool.admin.eval.description'),
              usage: I18n.t(:'commands.tool.admin.eval.usage'),
              help_available: false,
              permission_level: TohsakaBot.permissions.roles["owner"]) do |event|
        # Hard coded to allow ONLY the owner to have access.
        break unless event.user.id == AUTH.owner_id.to_i

        command = CommandLogic::Eval.new(event, event.message.content[5..])
        event.respond(command.run[:content])
      end


      command(:tester,
              aliases: %i[test t],
              description: 'Command for testing stuff',
              usage: 'test') do |event|
        event.<< event.message.content
      end


      command(:editpermissions,
              aliases: TohsakaBot.get_command_aliases('commands.tool.admin.edit_permissions.aliases'),
              description:  I18n.t(:'commands.tool.admin.edit_permissions.description'),
              usage:  I18n.t(:'commands.tool.admin.edit_permissions.usage'),
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["permissions"]) do |event, user, level|
        command = CommandLogic::EditPermissions.new(event, user, level)
        event.respond(command.run[:content])
      end


      command(:setstatus,
              aliases: %i[np],
              description: 'Now playing status.',
              usage: 'np <type (playing, watching, listening, competing)> <status>',
              min_args: 2,
              permission_level: TohsakaBot.permissions.actions["set_status"]) do |event, type, *msg|
        msg = msg.join(' ')
        type = "playing" unless %w[playing watching listening streaming competing].include?(type)

        TohsakaBot.status(type, msg)
        cfg = YAML.load_file("cfg/config.yml")
        cfg["status"] = [type, msg]

        File.open('cfg/config.yml', 'w') { |f| f.write cfg.to_yaml }
        event.respond("Status changed to `#{msg.strip_mass_mentions}` as `#{type}`.")
      end


      command(:prune,
              description: 'Prunes between 2 and 100 messages in the current channel.',
              usage: 'prune <amount (2-100)>',
              permission_level: TohsakaBot.permissions.actions["message_prune"]) do |event, amount|
        if /\A\d+\z/.match(amount) && (2..100).include?(amount.to_i)
          event.channel.prune(amount.to_i)
          break
        else
          event.respond('The amount of messages has to be between 2 and 100.')
        end
      end


      command(:typing,
              aliases: %i[type],
              description: 'Starts typing.',
              permission_level: TohsakaBot.permissions.actions["typing_event"],
              usage: 'typing <how long (minutes, default is unlimited)>') do |event, duration|
        if event.channel.pm?
          event.<< 'Not allowed in private messages.'
          break
        end

        TohsakaBot.manage_typing(event.channel, duration)
        break
      end


      command(:convertpins,
              description: 'Copies all pinned messages on the specified channel to database and posts them to the highlight channel',
              usage: 'convertpins <Newest|oldest (starting point)> <channel_id (if empty, current channel will be used)> ',
              permission_level: TohsakaBot.permissions.actions["convert_pins"]) do |event, order, channel_id|
        channel = if channel_id.nil?
                    event.channel
                  else
                    BOT.channel(channel_id.to_i)
                  end

        pinned_messages = channel.pins
        pinned_messages.reverse! if !order.nil? && order == 'oldest'

        msg = event.respond('Converting...')

        pinned_messages.each do |m|
          next unless TohsakaBot.db[:highlights].where(msg_id: m.id.to_i).empty?

          highlight_core = HighlightCore.new(m, channel.server.id.to_i, channel.id.to_i)
          highlight_core.store_highlight(highlight_core.send_highlight)
          sleep(2)
        end

        msg.edit('Done!')
        break
      end


      command(:emojilist,
              aliases: %i[emoji le],
              description: 'List all the 絵文字 bot has at its disposal.',
              usage: 'emojis') do |event|
        every_emoji = BOT.emoji
        i = 0
        emoji_names = []
        until i == every_emoji.count
          if event.server != every_emoji[i].server
            emoji_names << every_emoji[i].name
          elsif event.server == every_emoji[i].server && every_emoji[i].animated
            emoji_names << every_emoji[i].name
          end
          i += 1
        end

        event.<< "```#{emoji_names.join(' ')}```"
      end


      command(:slowmode,
              aliases: TohsakaBot.get_command_aliases('commands.tool.admin.slow_mode.aliases'),
              description: I18n.t(:'commands.tool.admin.slow_mode.description'),
              usage: I18n.t(:'commands.tool.admin.slow_mode.usage'),
              permission_level: TohsakaBot.permissions.actions["slow_mode"],
              min_args: 1) do |event, rate, *channels|
        command = CommandLogic::SlowMode.new(event, rate, channels)
        event.respond(command.run[:content])
      end
    end
  end
end
