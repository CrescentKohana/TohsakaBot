module TohsakaBot
  module Commands
    module TriggerDel
      extend Discordrb::Commands::CommandContainer
      command(:triggerdel,
              aliases: %i[deltrigger donttrigger remtrigger triggerrem],
              description: 'Deletes a trigger.',
              usage: 'deltrigger <ids separeted by space (integer)>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *ids|

        triggers = YAML.load_file('data/triggers.yml')
        i = 0
        triggers.each do |key, value|
          ids.each do |x|
            if event.author.id.to_i == value["user"].to_i && key.to_i == ids[i].to_i
              i += 1
              unless value["file"].to_s.empty?
                File.delete(value["file"].to_s)
              end
              rstore = YAML::Store.new('data/triggers.yml')
              rstore.transaction do
                rstore.delete(key)
                rstore.commit
              end
              @check = 1
              next
            end
          end
        end

        if defined? @check
          event.<< 'Trigger(s) deleted.'
        else
          event.<< 'One or more IDs were not found within your list of triggers.'
        end
      end
    end
  end
end
