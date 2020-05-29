module TohsakaBot
  module Commands
    module TriggerMod
      # TODO: REFACTOR!
      extend Discordrb::Commands::CommandContainer
      command(:triggermod,
              aliases: %i[modtrigger tm modt tmod mtrigger edittrigger editrigger triggeredit tedit editt],
              description: 'Edit triggers.',
              usage:
                  "triggermod <id> --t(rigger) <new trigger> --r(esponse) <new response> --m(ode) <N(ormal)|a(ny)>" +
                  "\nEmbedded image replaces response arg.",
              min_args: 1,
              require_register: true,
              rescue: "`%exception%`") do |event, id, *msg|

        current_user = event.author.id.to_i

        TohsakaBot.trigger_data.full_triggers.each do |k, v|
          if k.to_i == id.to_i
            if v.user == current_user
              
            else
              raise "No permissions to edit this trigger."
            end
          else
            raise "No trigger for the specified ID was found."
          end
        end

        args = msg.join(' ')
        options = {}

        OptionParser.new do |opts|
          opts.on('--trigger PHRASE', String)
          opts.on('--response RESPONSE', String)
          opts.on('--mode MODE', String)
        end.parse!(Shellwords.shellsplit(args), into: options)

        trg = TriggerSession.new(event, msg)
        if !event.message.attachments.first.nil?
          filename = trg.download_response_picture(event)
          trg.add_new_trigger(filename: filename)
        else
          event.respond('Tell me the response (10s remaining).')
          response = event.message.await!(timeout: 10)
          if response
            if !response.message.attachments.first.nil?
              filename = trg.download_response_picture(response)
              id = trg.add_new_trigger(filename: filename)
            else
              id = trg.add_new_trigger(response: response.message.content)
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
