# frozen_string_literal: true

module TohsakaBot
  module Commands
    module AskRin
      extend Discordrb::Commands::CommandContainer
      command(:askrin,
              aliases: %i[ask rin],
              description: 'Ask Rin about something and she will deliver.',
              usage: 'askrin <question>',
              min_args: 1) do |event|
        answer = ''

        CSV.open('data/ask_rin_answers.csv', 'r', col_sep: "\t") do |csv|
          answer = csv.read.sample[0]
        end

        event.message.reply!(answer.to_s, allowed_mentions: false)
      end
    end
  end
end
