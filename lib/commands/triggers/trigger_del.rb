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

        discord_uid = event.author.id.to_i

        begin
          user_id = TohsakaBot.get_user_id(discord_uid)
        rescue
          event.respond "You aren't registered yet! Please do so by entering the command '#{CFG.prefix}register'."
          break
        end

        # TODO: Proper permissions.
        # # no_permission, deleted = [], []
        admin = [73510616697929728, 73086349363650560]

        deleted = []
        file_to_be_deleted = []
        ids.map!(&:to_i)
        triggers = TohsakaBot.db[:triggers]

        if admin.include?(discord_uid)
          TohsakaBot.db.transaction do
            ids.each do |id|
              file = triggers.where(:id => id.to_i).single_record![:file]
              if triggers.where(:id => id.to_i).delete > 0
                deleted << id
                file_to_be_deleted << file
              end
            end
          end
        else
          TohsakaBot.db.transaction do
            ids.each do |id|
              file = triggers.where(:id => id.to_i).single_record![:file]
              if triggers.where(:user_id => user_id, :id => id.to_i).delete > 0
                deleted << id
                file_to_be_deleted << file
              end
            end
          end
        end

        file_to_be_deleted.each do |f|
          File.delete("data/triggers/#{f}") unless f.blank?
        end

        #unless no_permission.empty?
        #  event.<< "No permissions to delete these triggers. "# TODO: #{no_permission.join(', ')}
        #end

        if deleted.size > 0
          TohsakaBot.trigger_data.reload_active
          event.<< "Trigger#{'s' if ids.length > 1} deleted: #{deleted.join(', ')}."
        else
          event.<< 'No triggers were deleted.'
        end
      end
    end
  end
end
