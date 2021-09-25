# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerDetails
      extend Discordrb::Commands::CommandContainer
      command(:triggerbyid,
              aliases:  TohsakaBot.get_command_aliases('commands.trigger.by_id.aliases'),
              description: I18n.t(:'commands.trigger.by_id.description'),
              usage: I18n.t(:'commands.trigger.by_id.usage'),
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, id|

        if Integer(id, exception: false)
          event.respond(I18n.t(:'errors.nan'))
          break
        end

        trigger = TohsakaBot.db[:triggers].where(id: id.to_i).single_record!

        if trigger.nil?
          event.respond(I18n.t(:'commands.trigger.by_id.errors.not_found'))
          break
        end

        event.respond(trigger[:reply])
      end
    end
  end
end
