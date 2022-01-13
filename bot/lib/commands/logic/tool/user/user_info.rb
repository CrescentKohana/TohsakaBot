# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class UserInfo
      def initialize(event, user_id)
        @event = event
        @user = if user_id.nil?
                  TohsakaBot.command_event_user_id(@event, return_id: false)
                else
                  BOT.user(user_id)
                end
      end

      def run
        return { content: I18n.t(:'commands.tool.user.info.error.not_found') } if @user.nil?

        if @event.channel.pm?
          nickname = ""
          groups = ""
        else
          server_member = BOT.member(@event.server.id, @user.id)
          nickname = "   Nickname: #{server_member.display_name}\n"
          groups = (server_member.roles.map { |r| "`#{r.name}`" } - ['`@everyone`']).sort.join(' ')
        end

        locale = nil
        permissions = nil
        birthday = nil
        internal_id = TohsakaBot.get_user_id(@user.id)
        unless internal_id.nil?
          internal_user = TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(@user.id)).single_record!
          permissions = internal_user[:permissions].nil? ? "" : "Permissions: #{internal_user[:permissions]}\n"
          birthday = if internal_user[:birthday].nil?
                       ""
                     else
                       "   Birthday: #{internal_user[:birthday]}\n"
                     end
          locale = internal_user[:locale].nil? ? "" : "     Locale: #{internal_user[:locale]}\n"
        end

        builder = Discordrb::Webhooks::Builder.new
        builder.add_embed do |e|
          e.title = "#{@user.username}##{@user.discriminator}"
          e.colour = 0xE91E53
          e.description = "```"\
                          "#{nickname}"\
                          "         ID: #{@user.id}\n"\
                          "    Created: #{TohsakaBot.account_created_date(@user.id)}\n"\
                          "#{permissions}"\
                          "#{birthday}"\
                          "#{locale}"\
                          "```"
          e.add_field(name: 'Roles', value: groups) unless @event.channel.pm?
          e.image = Discordrb::Webhooks::EmbedImage.new(url: @user.avatar_url)
        end

        { content: nil, embeds: builder.embeds.map(&:to_hash) }
      end
    end
  end
end
