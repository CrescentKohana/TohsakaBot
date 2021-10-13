# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TriggerDel
      extend Discordrb::Commands::CommandContainer
      command(:triggerdel,
              aliases: TohsakaBot.get_command_aliases('commands.trigger.del.aliases'),
              description: I18n.t(:'commands.trigger.del.description'),
              usage: I18n.t(:'commands.trigger.del.usage'),
              min_args: 1,
              require_register: true) do |event, *ids|
        discord_uid = event.author.id.to_i
        user_id = TohsakaBot.get_user_id(discord_uid)

        deleted = []
        file_to_be_deleted = []
        ids.map!(&:to_i)
        triggers = TohsakaBot.db[:triggers]

        if TohsakaBot.permissions.able?(discord_uid, "trigger_management", :perm)
          TohsakaBot.db.transaction do
            ids.each do |id|
              file = triggers.where(id: id.to_i).single_record!
              next if file.nil?

              if triggers.where(id: id.to_i).delete.positive?
                deleted << id
                file_to_be_deleted << file[:file]
              end
            end
          end
        else
          TohsakaBot.db.transaction do
            ids.each do |id|
              file = triggers.where(id: id.to_i).single_record!
              next if file.nil?

              if triggers.where(user_id: user_id, id: id.to_i).delete.positive?
                deleted << id
                file_to_be_deleted << file[:file]
              end
            end
          end
        end

        file_to_be_deleted.each do |f|
          File.delete("data/triggers/#{f}") unless f.blank?
        end

        # unless no_permission.empty?
        #   event.<< "No permissions to delete these triggers. "# TODO: #{no_permission.join(', ')}
        # end

        if deleted.size.positive?
          TohsakaBot.trigger_data.reload_active
          event.<< I18n.t(:'commands.trigger.del.response', plural: ids.length > 1 ? "s" : "", ids: deleted.join(', '))
        else
          event.<< I18n.t(:'commands.trigger.del.errors.not_found')
        end
      end
    end
  end
end
