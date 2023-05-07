# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerDetails
      extend Discordrb::Commands::CommandContainer
      command(:triggerbyid,
              aliases:  TohsakaBot.get_command_aliases('commands.trigger.by_id.aliases'),
              description: I18n.t(:'commands.trigger.by_id.description'),
              usage: I18n.t(:'commands.trigger.by_id.usage'),
              require_register: true,
              enabled_in_pm: false) do |event, id|
        trigger = if Integer(id, exception: false).nil?
                    TohsakaBot.db[:triggers].to_a.sample
                  else
                    TohsakaBot.db[:triggers].where(id: id.to_i).single_record!
                  end

        if trigger.nil?
          event.respond(I18n.t(:'commands.trigger.by_id.errors.not_found'))
          break
        end

        if trigger[:file].blank?
          event.respond(trigger[:reply], false, nil, nil, false)
        else
          event.channel.send_file(File.open(CFG.data_dir + "/triggers/#{trigger[:file]}"))
        end

        TohsakaBot.db.transaction do
          TohsakaBot.db[:triggers].where(id: trigger[:id]).update(
            calls: trigger[:calls] + 1,
            last_triggered: TohsakaBot.time_now
          )
        end
        break
      end
    end
  end
end
