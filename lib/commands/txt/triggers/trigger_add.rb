# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerAdd
      extend Discordrb::Commands::CommandContainer
      command(:triggeradd,
              aliases: TohsakaBot.get_command_aliases('commands.trigger.add.aliases'),
              description: I18n.t(:'commands.trigger.add.description'),
              usage: I18n.t(:'commands.trigger.add.usage'),
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, *msg|
        if TohsakaBot.user_limit_reached?(event.author.id, CFG.trigger_limit, :triggers)
          event.respond "The the maximum amount of triggers a user can have is #{CFG.trigger_limit}. "\
                        'They can be removed using `deltrigger <id(s separated by space)>`.'
          break
        end

        extra_help = "If a file is attached to the command, that'll be used instead of reply. "\
                     'If a phrase and no reply is given, '\
                     'the bot will ask for the reply (text|file) after the command. '\
                     'Example: `triggeradd -p msg from which the bot triggers -m exact` with an image embedded as a reply.'

        options = TohsakaBot.command_parser(
          event, msg, 'Usage: triggeradd [options]', extra_help,
          [:phrase, 'Message from which the bot triggers.', { type: :strings }],
          [:reply, 'Message which the bot sends.', { type: :strings }],
          [:mode, 'A(ny) <anywhere in the msg> \|\| e(xact) <has to be an exact match> \|\| r(egex)', { type: :string }]
        )
        break if options.nil?

        phrase = options.phrase.nil? ? nil : options.phrase.join(' ')
        if phrase.nil?
          event.respond '-p, --phrase is required.'
          break
        end

        reply = options.reply.nil? ? nil : options.reply.join(' ')
        mode = options.mode

        unless options.mode.nil?
          mode = TriggerController.select_mode(options.mode, event.author.id.to_i)
          if mode.nil?
            event.respond('No permissions for regex mode.')
            break
          end
        end

        trg = TriggerController.new(event, phrase, mode)
        if !event.message.attachments.first.nil?
          filename = TriggerController.download_reply_picture(event)
          if filename.nil?
            event.respond('File too large. Max: ~8MiB or 8388119 bytes.')
            break
          end
          reply = trg.store_trigger(filename: filename)

        elsif !reply.blank?
          reply = trg.store_trigger(reply: reply)

        else
          event.respond('Tell me the response (10s remaining).')
          response = event.message.await!(timeout: 10)

          if response
            if !response.message.attachments.first.nil?
              filename = TriggerController.download_reply_picture(response)
              if filename.nil?
                event.respond('File too large. Max: ~8MiB or 8388119 bytes.')
                break
              end
              reply = trg.store_trigger(filename: filename)
            else
              reply = trg.store_trigger(reply: response.message.content)
            end

          else
            event.respond('You took too long!')
            break
          end
        end

        event.respond(reply)
        break
      end
    end
  end
end
