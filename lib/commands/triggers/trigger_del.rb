module TohsakaBot
  module Commands
    module TriggerDel
      extend Discordrb::Commands::CommandContainer
      command(:triggerdel,
              aliases: %i[td deltrigger deletetrigger triggerdelete removetrigger triggerremove donttrigger remtrigger triggerrem],
              description: 'Deletes a trigger.',
              usage: 'deltrigger <ids separeted by space (integer)>',
              min_args: 1,
              require_register: true) do |event, *ids|

        discord_uid = event.author.id.to_i
        user_id = TohsakaBot.get_user_id(discord_uid)

        trigger_control_perm_users = TohsakaBot.get_users_at_perm_level(500)

        deleted = []
        file_to_be_deleted = []
        ids.map!(&:to_i)
        triggers = TohsakaBot.db[:triggers]

        if trigger_control_perm_users.include?(discord_uid)
          TohsakaBot.db.transaction do
            ids.each do |id|
              file = triggers.where(:id => id.to_i).single_record!
              unless file.nil?
                if triggers.where(:id => id.to_i).delete > 0
                  deleted << id
                  file_to_be_deleted << file[:file]
                end
              end
            end
          end
        else
          TohsakaBot.db.transaction do
            ids.each do |id|
              file = triggers.where(:id => id.to_i).single_record!
              unless file.nil?
                if triggers.where(:user_id => user_id, :id => id.to_i).delete > 0
                  deleted << id
                  file_to_be_deleted << file[:file]
                end
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
          event.<< 'One or more IDs were not found within list of your triggers.'
        end
      end
    end
  end
end
