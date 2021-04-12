# frozen_string_literal: true

module TohsakaBot
  module Commands
    module UserInfo
      extend Discordrb::Commands::CommandContainer
      command(:info,
              aliases: TohsakaBot.get_command_aliases('commands.utility.user_info.aliases'),
              description: I18n.t(:'commands.utility.user_info.description'),
              usage: I18n.t(:'commands.utility.user_info.usage')) do |event, user|
        discord_user = if user.nil?
                         event.author
                       else
                         BOT.user(TohsakaBot.discord_id_from_mention(user))
                       end

        bot_user = TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(discord_user.id)).single_record!
        if !event.channel.pm?
          server_member = BOT.member(event.server.id, discord_user.id)
          nickname = "   Nickname: #{server_member.display_name}\n"
          groups = (server_member.roles.map { |r| "`#{r.name}`" } - ['`@everyone`']).sort.join(' ').to_s
        else
          nickname = ""
          groups = ""
        end
        permissions = TohsakaBot.registered?(discord_user.id) ? "Permissions: #{bot_user[:permissions]}\n" : ""

        event.channel.send_embed do |embed|
          embed.title = "#{discord_user.username}##{discord_user.discriminator}"
          embed.colour = 0xE91E53
          # embed.url = ''
          embed.description = "```"\
                              "#{nickname}"\
                              "         ID: #{discord_user.id}\n"\
                              "    Created: #{TohsakaBot.account_created_date(discord_user.id)}\n"\
                              "#{permissions}"\
                              "     Locale: #{bot_user[:locale]}\n"\
                              "```"
          embed.add_field(name: 'Roles', value: groups)
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: discord_user.avatar_url)
        end
      end
    end
  end
end
