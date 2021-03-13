module TohsakaBot
  module Commands
    module ReminderDel
      extend Discordrb::Commands::CommandContainer
      command(:reminderdel,
              aliases: TohsakaBot.get_command_aliases('commands.reminder.del.aliases'),
              description: I18n.t(:'commands.reminder.del.description'),
              usage: I18n.t(:'commands.reminder.del.usage'),
              min_args: 1,
              require_register: true) do |event, *ids|

        deleted = []
        reminders = TohsakaBot.db[:reminders]
        user_id = TohsakaBot.get_user_id(event.author.id.to_i)

        TohsakaBot.db.transaction do
          ids.each do |id|
            deleted << id if reminders.where(user_id: user_id, id: id.to_i).delete.positive?
          end
        end

        event << if deleted.size.positive?
                   I18n.t(:'commands.reminder.del.response', plural: ids.length > 1 ? "s" : "", ids: deleted.join(', '))
                 else
                   I18n.t(:'commands.reminder.del.errors.not_found')
                 end
      end
    end
  end
end
