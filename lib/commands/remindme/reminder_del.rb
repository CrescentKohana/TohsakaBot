module TohsakaBot
  module Commands
    module ReminderDel
      extend Discordrb::Commands::CommandContainer
      command(:reminderdel,
              aliases: %i[delreminder dontremindme remrem remdel delrem remremind delremind],
              description: 'Deletes an active reminder.',
              usage: 'delreminder <ids separeted by space (integer)>',
              min_args: 1,
              require_register: true,
              rescue: "Something went wrong!\n`%exception%`") do |event, *ids|

        @check = 0
        reminders = TohsakaBot.db[:reminders]

        begin
          user_id = TohsakaBot.get_user_id(event.author.id.to_i)
        rescue
          event.respond "You aren't registered yet! Please do so by entering the command '?register'."
          break
        end

        TohsakaBot.db.transaction do
          ids.each do |id|
            @check = reminders.where(:user_id => user_id, :id => id.to_i).delete
          end
        end

        if @check > 0
          event.<< "#{@check} reminder(s) deleted."
        else
          event.<< 'One or more IDs were not found within your list of triggers.'
        end
      end
    end
  end
end
