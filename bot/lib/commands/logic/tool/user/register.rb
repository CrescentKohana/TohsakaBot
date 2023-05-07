# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Register
      def initialize(event)
        @event = event
      end

      def run
        user = TohsakaBot.command_event_user_id(@event, return_id: false)
        return { content: I18n.t(:'errors.unexpected') } if user.nil? || user.bot_account?

        permissions = user.id == AUTH.owner_id.to_i ? 1000 : 0

        users = TohsakaBot.db[:users]
        auths = TohsakaBot.db[:authorizations]
        return { content: I18n.t(:'commands.tool.user.register.error.found') } unless auths.where(uid: user.id).empty?

        TohsakaBot.db.transaction do
          user_id = users.insert(name: user.name,
                                 discriminator: user.discriminator,
                                 avatar: user.avatar_id,
                                 locale: '',
                                 permissions: permissions,
                                 created_at: TohsakaBot.time_now,
                                 updated_at: TohsakaBot.time_now)

          auths.insert(provider: 'discord',
                       uid: user.id,
                       user_id: user_id,
                       created_at: TohsakaBot.time_now,
                       updated_at: TohsakaBot.time_now)
        end
        { content: I18n.t(:'commands.tool.user.register.response') }
      end
    end
  end
end
