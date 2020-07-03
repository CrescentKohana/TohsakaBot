module TohsakaBot
  module Commands
    module TriggerAdd
      extend Discordrb::Commands::CommandContainer
      command(:triggeradd,
              aliases: %i[addtrigger trigger],
              description: 'Adds a trigger.',
              usage: "Use 'triggeradd -h|--help' for help.",
              min_args: 1,
              require_register: true) do |event, *msg|

        if TohsakaBot.user_limit_reached?(event.author.id, CFG.trigger_limit, :triggers)
          event.respond "Sorry, but the the limit for triggers per user is #{CFG.trigger_limit}! " +
                            "They can be removed using `triggers` & `deltrigger <id(s)>`."
          break
        end

        extra_help = "If a file is attached to the command, that'll be used instead of reply. "\
                     "If a phrase and no reply is given, "\
                     "the bot will ask for the reply (text|file) after the command."

        options = TohsakaBot.command_parser(
            event, msg, 'Usage: triggeradd [options]', extra_help,
            [:phrase, 'Message from which the bot triggers.', :type => :strings],
            [:reply, 'Message which the bot sends.', :type => :strings],
            [:mode, 'A(ny) phrase anywhere in the msg || e(xact) msg has to be a exact match', :type => :string]
        )
        break if options.nil?

        phrase = options.phrase.nil? ? nil : options.phrase.join(' ')
        if phrase.nil?
          event.respond '-p, --phrase is required.'
          break
        end

        reply = options.reply.nil? ? nil : options.reply.join(' ')
        mode = options.mode

        trg = TriggerController.new(event, phrase, mode)
        if !event.message.attachments.first.nil?
          filename = trg.download_reply_picture(event)
          id = trg.store_trigger(filename: filename)

        elsif !reply.blank?
          id = trg.store_trigger(reply: reply)

        else
          event.respond('Tell me the response (10s remaining).')
          response = event.message.await!(timeout: 10)

          if response
            if !response.message.attachments.first.nil?
              filename = trg.download_reply_picture(response)
              id = trg.store_trigger(filename: filename)
            else
              id = trg.store_trigger(reply: response.message.content)
            end

          else
            event.respond('You took too long!')
            break
          end
        end

        event.respond("Trigger added `<ID #{id}>`.")
      end
    end
  end
end
