module TohsakaBot
  module Commands
    module TriggerDel
      extend Discordrb::Commands::CommandContainer
      command(:triggerdel,
              aliases: %i[td deltrigger deletetrigger triggerdelete removetrigger triggerremove donttrigger remtrigger triggerrem],
              description: 'Deletes a trigger.',
              usage: 'deltrigger <ids separeted by space (integer)>',
              min_args: 1,
              rescue: "Something went wrong!\n`%exception%`") do |event, *ids|


        user = event.author.id.to_i
        # TODO: Proper permissions.
        admin = [73510616697929728, 73086349363650560]
        no_permission, deleted = [], []
        i = 0

        TohsakaBot.trigger_data.full_triggers.each do |key, value|
          ids.each do |k|

            if key.to_i == k.to_i
              if admin.include?(user.to_i) || user == value["user"].to_i

                i += 1
                unless value["file"].to_s.empty?
                  File.delete("triggers/#{value["file"]}")
                end

                rstore = YAML::Store.new('data/triggers.yml')
                rstore.transaction do
                  rstore.delete(key)
                  rstore.commit
                end
                deleted.push(key)
                next

              else
                no_permission.push(key)
              end
            end
          end
        end

        unless no_permission.empty?
          event.<< "No permissions to delete these triggers: #{no_permission.join(', ')}"
        end

        if !deleted.empty?
          event.<< "Trigger(s) deleted: #{deleted.join(', ')}"
        else
          event.<< 'No triggers were deleted.'
        end
      end
    end
  end
end
