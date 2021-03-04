module TohsakaBot
  module Commands
    module TriggerDetails
      extend Discordrb::Commands::CommandContainer
      command(:triggerdetails,
              aliases: %i[triggerdetail triggerdetail showtrigger triggerinfo infotrigger tinfo],
              description: 'Shows details about triggers.',
              usage: "Use 'triggerdetails <id>",
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, id|

        unless Integer(id, exception: false).nil?
          trigger = TohsakaBot.db[:triggers].where(id: id.to_i).single_record!
          unless trigger.nil?
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
              e.add_field(name: "Phrase <ID: #{id}>", value: "#{trigger[:phrase]}")
              e.add_field(name: 'Reply', value: trigger[:reply].to_s) unless trigger[:reply].empty?
              e.add_field(name: 'File', value: "[Link](https://rin.luukuton.fi/td/#{trigger[:file]})") unless trigger[:file].empty?
              e.add_field(name: 'Mode / Chance', value: "#{mode} / #{trigger[:chance]} %")
              e.add_field(name: 'Occurences + Calls', value: "#{trigger[:occurences]} + #{trigger[:calls]}")

              e.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Last trigger: #{trigger[:last_triggered]}", icon_url: '')
            end
            break
          end
        end

        event.respond("Specified trigger wasn't found.")
      end
    end
  end
end
