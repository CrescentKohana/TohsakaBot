module TohsakaBot
  module Commands
    module TriggerAdd
      # TODO: REFACTOR!
      extend Discordrb::Commands::CommandContainer
      command(:triggeradd,
              aliases: %i[addtrigger trigger],
              description: 'Adds a trigger.',
              usage: 'triggeradd '\
                      '--p(hrase) <msg from which the bot triggers (text)> '\
                      '--r(eply) <msg which the bot sends (text)> '\
                      '--m(ode) <A(ny)> | n(ormal) '\
                      "\n`If **a file is attached** to the command, that'll be used **instead of reply**. "\
                      "If **a phrase** and **no reply** is given, "\
                      'the bot will ask for the reply (text|file) after the command.',
              min_args: 1,
              require_register: true) do |event, *msg|

        if TohsakaBot.user_limit_reached?(event.author.id, CFG.trigger_limit, :triggers)
          event.respond "Sorry, but the the limit for triggers per user is #{CFG.trigger_limit}! " +
                            "They can be removed using `triggers` & `deltrigger <id(s)>`."
          break
        end

        args = msg.join(' ')
        options = {}

        begin
          OptionParser.new do |opts|
            opts.on('--phrase PHRASE', String)
            opts.on('--reply REPLY', String)
            opts.on('--mode MODE', String)
          end.parse!(Shellwords.shellsplit(args), into: options)

          phrase = options[:phrase]
          reply = options[:reply]
          if phrase.blank?
            event.respond '--p(hrase) cannot be blank.'
            break
          end
        rescue OptionParser::InvalidOption => e
          event.respond "Tried to use an #{e}."
          break
        end

        trg = TriggerController.new(event, phrase, options[:mode])
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
