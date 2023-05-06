# frozen_string_literal: true

module TohsakaBot
  module Commands
    module AnswerAdd
      extend Discordrb::Commands::CommandContainer
      command(:answeradd,
              aliases: %i[addanswer adda answer],
              description: 'Adds an answer to the list.',
              usage: 'addanswer <text>',
              require_register: true,
              min_args: 1) do |event, *msg|
        answer = msg.join(' ').delete("\t").sanitize_string
        exists = false

        CSV.foreach(CFG.data_dir + '/ask_rin_answers.csv', 'r', col_sep: "\t") do |row|
          if answer == row[0]
            event.respond 'Answer already exists. Aborting.'
            exists = true
            break
          end
        end
        break if exists

        CSV.open(CFG.data_dir + '/ask_rin_answers.csv', 'a', col_sep: "\t") do |csv|
          csv << [answer, event.user.id]
        end
        event.respond 'Answer added.'
      end
    end
  end
end
