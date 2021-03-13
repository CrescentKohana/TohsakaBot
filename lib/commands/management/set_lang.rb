# frozen_string_literal: true

module TohsakaBot
  module Commands
    module SetLang
      extend Discordrb::Commands::CommandContainer
      command(:setlang,
              aliases: TohsakaBot.get_command_aliases('commands.management.set_lang.aliases'),
              description: I18n.t(:'commands.management.set_lang.description'),
              usage: I18n.t(:'commands.management.set_lang.usage'),
              min_args: 1,
              require_register: true) do |event, locale|
        if %w[en ja fi].include? locale
          TohsakaBot.db.transaction do
            TohsakaBot.db[:users].where(id: TohsakaBot.get_user_id(event.author.id)).update(
              locale: locale
            )
          end
          event.respond(I18n.t(:'commands.management.set_lang.response',
                               locale: TohsakaBot.get_locale(event.user.id).to_sym))
        else
          event.respond(I18n.t(:'commands.management.set_lang.errors.locale_not_found',
                               locale: TohsakaBot.get_locale(event.user.id).to_sym))
        end
      end
    end
  end
end
