# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class EditPermissions
      def initialize(event, user, level)
        @event = event
        @discord_user = BOT.user(TohsakaBot.discord_id_from_mention(user))
        @level = level.to_i
      end

      def run
        user_id = TohsakaBot.command_event_user_id(@event)
        return unless TohsakaBot.permissions.able?(user_id, "permissions", :perm)
        return { content: I18n.t(:'commands.tool.admin.edit_permissions.error.user_not_found') } if @discord_user.nil?

        if @level.nil? || !(0..999).include?(@level)
          return { content: I18n.t(:'commands.tool.admin.edit_permissions.error.level_not_in_range') }
        end

        if TohsakaBot.permissions.set_level(@discord_user.id, @level).nil?
          return {
            content: I18n.t(:'commands.tool.admin.edit_permissions.error.failed', username: "<@!#{@discord_user.id}>")
          }
        end

        {
          content: I18n.t(
            :'commands.tool.admin.edit_permissions.response',
            level: @level.to_s, username: "<@!#{@discord_user.id}>"
          )
        }
      end
    end
  end
end
