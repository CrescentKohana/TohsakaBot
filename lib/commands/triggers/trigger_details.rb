# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerDetails
      extend Discordrb::Commands::CommandContainer
      command(:triggerdetails,
              aliases: %i[triggerdetail triggerdetail showtrigger triggerinfo infotrigger tinfo],
              description: 'Shows details about triggers.',
              usage: "Use 'triggerdetails <id> <verbose>",
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, id, verbose|
        verbose = verbose.nil? ? false : true
        unless Integer(id, exception: false).nil?
          trigger = TohsakaBot.db[:triggers].where(id: id.to_i).single_record!
          unless trigger.nil?
            server = BOT.server(trigger[:server_id].to_i).name
            chance = TohsakaBot.trigger_data.parse_chance(trigger[:chance], trigger[:mode])
            last_triggered = !trigger[:last_triggered].nil? ? trigger[:last_triggered] : ""
            mode = case trigger[:mode]
                   when 2
                     "Regex"
                   when 1
                     "Any"
                   else
                     "Exact"
                   end

            event.channel.send_embed do |e|
              e.colour = 0xA82727
              e.add_field(name: "ID: #{id} by [redacted]", value: "on **#{server}**")
              e.add_field(name: "Phrase", value: (trigger[:phrase]).to_s)
              unless trigger[:reply].nil? || trigger[:reply].empty?
                e.add_field(name: 'Reply', value: trigger[:reply].to_s)
              end
              unless trigger[:file].nil? || trigger[:file].empty?
                e.add_field(name: 'File', value: "[Link](https://rin.luukuton.fi/td/#{trigger[:file]})")
              end
              e.add_field(name: 'Mode / Chance', value: "#{mode} / #{chance} %")
              e.add_field(name: 'Occurrences + Calls', value: "#{trigger[:occurences]} + #{trigger[:calls]}")
              e.add_field(name: 'Created At', value: trigger[:created_at].to_s) if verbose
              e.add_field(name: 'Updated At', value: trigger[:updated_at].to_s) if verbose
              e.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Last triggered: #{last_triggered}")
            end
            break
          end
        end

        event.respond("Specified trigger wasn't found.")
      end
    end
  end
end
