module TohsakaBot
  module Commands
    module TriggerAdd
      # TODO: REFACTOR!
      extend Discordrb::Commands::CommandContainer
      command(:triggeradd,
              aliases: %i[addtrigger trigger],
              description: 'Adds a trigger.',
              usage: 'addtrigger <trigger phrase> (--reg enables regex, --any matches the trigger everywhere in the msg)',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|

        if user_limit_reached?("data/triggers.yml", $settings["trigger_limit"], event.message.user.id)
          event.respond "Sorry, but the the limit for triggers per user is #{$settings["trigger_limit"]}! " +
                            "They can be removed using `triggers` & `deltrigger <id(s)>`."
          break
        end

        trg = TriggerCore.new(event, msg)

        if !event.message.attachments.first.nil?
          filename = trg.download_response_picture
          id = trg.add_new_trigger(filename: filename)
        else
          event.respond 'Tell me the response (10s remaining).'
          response = event.message.await!(timeout: 10)
          if response
            if !response.message.attachments.first.nil?
              filename = trg.download_response_picture
              id = trg.add_new_trigger(filename: filename)
            else
              id =  trg.add_new_trigger(response: response.message.content)
            end
          else
            event.respond('You took too long!')
            break
          end
        end
        event.respond "Trigger added `<ID #{id}>`."
      end
    end
  end
end
