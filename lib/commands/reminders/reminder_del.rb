module TohsakaBot
  module Commands
    module ReminderDel
      extend Discordrb::Commands::CommandContainer
      command(:reminderdel,
              aliases: %i[delreminder dontremindme remrem remdel delrem remremind delremind],
              description: 'Deletes an active reminder.',
              usage: 'delreminder <ids separeted by space (integer)>',
              min_args: 1,
              require_register: true) do |event, *ids|

        deleted = []
        reminders = TohsakaBot.db[:reminders]
        user_id = TohsakaBot.get_user_id(event.author.id.to_i)

        TohsakaBot.db.transaction do
          ids.each do |id|
            deleted << id if reminders.where(:user_id => user_id, :id => id.to_i).delete > 0
          end
        end

        if deleted.size > 0
          event.<< "Reminder#{'s' if ids.length > 1} deleted: #{deleted.join(', ')}."
        else
          event.<< 'One or more IDs were not found within list of your reminders.'
        end
      end
    end
  end
end
