module TohsakaBot
  module Commands
    module TriggerAdd
      # TODO: REFACTOR!
      extend Discordrb::Commands::CommandContainer
      command(:triggeradd,
              aliases: %i[addtrigger trigger],
              description: 'Adds a trigger.',
              usage: 'addtrigger <trigger phrase> (--any matches the trigger everywhere in the msg)',
              min_args: 1,
              require_register: true,
              rescue: "%exception%") do |event, *msg|

        if TohsakaBot.user_limit_reached?(event.author.id, CFG.trigger_limit, :triggers)
          event.respond "Sorry, but the the limit for triggers per user is #{CFG.trigger_limit}! " +
                            "They can be removed using `triggers` & `deltrigger <id(s)>`."
          break
        end


        trg = TriggerController.new(event, msg)
        if !event.message.attachments.first.nil?
          filename = trg.download_response_picture(event)
          id = trg.store_trigger(filename: filename)

        else
          event.respond('Tell me the response (10s remaining).')
          response = event.message.await!(timeout: 10)

          if response
            if !response.message.attachments.first.nil?
              filename = trg.download_response_picture(response)
              id = trg.store_trigger(filename: filename)
            else
              id = trg.store_trigger(response: response.message.content)
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
