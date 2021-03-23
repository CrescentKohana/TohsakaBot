# frozen_string_literal: true

module TohsakaBot
  module Commands
    module GetPitch
      extend Discordrb::Commands::CommandContainer
      command(:getpitch,
              aliases: TohsakaBot.get_command_aliases('commands.japanese.get_pitch.aliases'),
              description: I18n.t(:'commands.japanese.get_pitch.description'),
              usage: I18n.t(:'commands.japanese.get_pitch.usage'),
              min_args: 1) do |event, word|
        results = TohsakaBot.get_accents(word)

        if results.blank?
          event.respond I18n.t(:'commands.japanese.get_pitch.errors.no_results')
          break
        end

        response = TohsakaBot.construct_response(results)

        event.channel.send_embed do |embed|
          embed.colour = 0x36393F
          embed.title = I18n.t(:'commands.japanese.get_pitch.response_title', word: response[0])
          embed.description = response[1]
        end
      end
    end
  end
end
