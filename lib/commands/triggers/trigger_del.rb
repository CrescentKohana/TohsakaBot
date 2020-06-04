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
          event.respond "You aren't registered yet! Please do so by entering the command '?register'."
          break
        end

        # TODO: Proper permissions.
        # # no_permission, deleted = [], []
        admin = [73510616697929728, 73086349363650560]

        @check = 0
        ids.map!(&:to_i)
        triggers = TohsakaBot.db[:triggers]

        if admin.include?(discord_uid)
          TohsakaBot.db.transaction do
            @deleted_triggers = triggers.where(:id => ids)
            @check =  @deleted_triggers.delete
          end
        else
          TohsakaBot.db.transaction do
            @deleted_triggers = triggers.where(:user_id => user_id, :id => ids)
            @check = @deleted_triggers.delete
          end
        end

        deleted_trigger_ids = @deleted_triggers.select{:id}.map{ |i| i.values}
        files_to_delete = @deleted_triggers.select{:file}.map{ |f| f.values}
        unless files_to_delete.nil? || files_to_delete.empty?
          files_to_delete.each do |f|
            File.delete("data/triggers/#{f}")
          end
        end

        #unless no_permission.empty?
        #  event.<< "No permissions to delete these triggers. "# TODO: #{no_permission.join(', ')}
        #end

        if @check > 0
          TohsakaBot.trigger_data.reload_active
          event.<< "#{@check} trigger#{'s' if ids.length > 1} deleted:#{deleted_trigger_ids.join(', ')}."
        else
          event.<< 'No triggers were deleted.'
        end
      end
    end
  end
end
