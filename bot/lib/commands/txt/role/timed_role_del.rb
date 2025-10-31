# frozen_string_literal: true

module TohsakaBot
  module Commands
    module TimedRoleDel
      extend Discordrb::Commands::CommandContainer
      command(:timedroledel,
              aliases: TohsakaBot.get_command_aliases('commands.roles.timed_role.del.aliases'),
              description: I18n.t(:'commands.roles.timed_role.del.description'),
              usage: I18n.t(:'commands.roles.timed_role.del.usage'),
              enabled_in_pm: false,
              min_args: 1) do |event, *ids|
        deleted_ids = Set.new
        roles = Set.new
        ids.each do |k|
          id = k.to_i
          next if deleted_ids.include? id

          db = YAML::Store.new(CFG.data_dir + '/timed_roles.yml')
          db.transaction do
            next if db[id].nil?
            next unless db[id][:user].to_i == event.author.id.to_i

            db[id][:roles].each { |role| roles.add(role) }
            deleted_ids.add(id)
            db.delete(id)
            db.commit
          end
        end

        if deleted_ids.empty?
          event.respond(I18n.t(:'commands.roles.timed_role.errors.id_not_found'))
        else
          roles.each do |role|
            # TODO: Multiple server support (id)
            found_role = BOT.server(event.server.id).roles.find { |r| r.name == role }
            next if found_role.nil?
            next unless TohsakaBot::BOT.member(event.server.id, event.author.id)&.role?(found_role.id)

            Discordrb::API::Server.remove_member_role(
              "Bot #{AUTH.bot_token}", event.server.id, event.author.id, found_role.id
            )
          end
          event.respond(I18n.t(:'commands.roles.timed_role.del.response', ids: deleted_ids.join(", ")))
        end
      end
    end
  end
end
