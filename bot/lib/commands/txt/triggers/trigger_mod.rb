# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerMod
      extend Discordrb::Commands::CommandContainer
      command(:triggermod,
              aliases: %i[?trigermod tm triggermodify modtrigger modifytrigger edittrigger triggeredit modtriger],
              description: 'Edits a trigger.',
              usage: "Use 'triggermod -h|--help' for help.",
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, *msg|
        discord_uid = event.author.id.to_i
        trigger_control_permisson = TohsakaBot.permissions.able?(discord_uid, "trigger_management", :perm)

        extra_help = 'Example: `triggermod -i 420 -p new trigger -r new response -c 100`'

        options = TohsakaBot.command_parser(
          event, msg,
          'Usage: triggermod [-i id] [-p triggering phrase] [-r new reply] [-f new file] [-m new mode] [-c new chance]',
          extra_help,
          [:id, 'Trigger id to edit', { type: :string }],
          [:phrase, 'Edit the phrase the bot triggers on.', { type: :strings }],
          [:reply, 'Edit the text the bot responds with.', { type: :strings }],
          [:file, 'Edit the file the bot responds with.'],
          [:mode, 'Edit the trigger mode. See `triggeradd --help` for more details.', { type: :string }],
          [:chance, 'Edit the chance of this trigger triggering [admin only; integer between 0 and 100]', { type: :integer }]
        )
        break if options.nil?

        if options.id.nil?
          event.respond('Specify a trigger ID to edit')
          break
        end

        triggers = TohsakaBot.db[:triggers]
        trigger = triggers.where(id: options.id.to_i).single_record!

        if trigger.nil?
          event.respond('Could not find trigger with that ID')
          break
        end

        if (trigger[:user_id] != TohsakaBot.get_user_id(discord_uid)) && !trigger_control_permisson
          event.respond('No permissions to edit this trigger')
          break
        end

        if options.phrase.nil? && options.reply.nil? && options.mode.nil? && options.file.nil? && options.chance.nil?
          event.respond('Specify an action')
          break
        elsif !options.file.nil? && !options.reply.nil?
          event.respond('Cannot edit both file and reply at the same time.')
          break
        end

        phrase = options.phrase.nil? ? nil : options.phrase.join(' ')
        trigger[:phrase] = phrase unless phrase.nil?

        unless options.mode.nil?
          trigger[:mode] = TriggerController.select_mode(options.mode, discord_uid)
          if trigger[:mode].nil?
            event.respond(I18n.t(:'commands.trigger.errors.regex_permissions'))
            break
          end
        end

        unless options.reply.nil?
          reply = options.reply.join(' ')
          trigger[:reply] = reply

          File.delete(CFG.data_dir + "/triggers/#{trigger[:file]}") unless trigger[:file].blank?
          trigger[:file] = nil
        end

        if !options.chance.nil? && trigger_control_permisson
          chance = options.chance
          trigger[:chance] = chance if (chance >= 0) && (chance <= 100)
        end

        unless options.file.nil?
          old_file = trigger[:file]

          if !event.message.attachments.first.nil?
            filename = TriggerController.download_reply_picture(event)
            if filename.nil?
              event.respond('File too large. Max: ~8MiB or 8388119 bytes.')
              break
            end
            trigger[:reply] = nil
            trigger[:file] = filename
            File.delete(CFG.data_dir + "/triggers/#{old_file}") unless old_file.blank?
          else
            event.respond('Tell me the response (10s remaining).')
            response = event.message.await!(timeout: 10)

            if response
              unless response.message.attachments.first.nil?
                filename = TriggerController.download_reply_picture(response)
                if filename.nil?
                  event.respond('File too large. Max: ~8MiB or 8388119 bytes.')
                  break
                end
                trigger[:reply] = nil
                trigger[:file] = filename
                File.delete(CFG.data_dir + "/triggers/#{old_file}") unless old_file.blank?
              end
            else
              event.respond('You took too long!')
              break
            end
          end
        end

        msg = TriggerController.update_trigger(trigger)
        event.respond(msg)
      end
    end
  end
end
