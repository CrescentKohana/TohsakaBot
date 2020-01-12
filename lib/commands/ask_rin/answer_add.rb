module TohsakaBot
  module Commands
    module AnswerAdd
      extend Discordrb::Commands::CommandContainer
      command(:answeradd,
              aliases: %i[addanswer adda answer],
              description: 'Adds an answer to the list.',
              usage: 'addanswer <answer (or an embedded image)>',
              rescue: "Something went wrong!\n`%exception%`") do |event, *msg|

        if event.message.attachments.first.nil?
          if !msg.nil?
            answer = msg.join(' ').gsub("\t", '').sanitize_string
          else
            event.respond "Message or an embbedded image is required."
            break
          end
        else
          # TODO: This needs to be more robust! Currently to easy to circumvent.
          supported_file_types = %w[.jpg .png .gif jpeg]
          answer = event.message.attachments.first.url
          unless supported_file_types.include? answer[-4..-1]
              event.respond "Only images allowed."
              break
          end
        end

        CSV::foreach("data/ask_rin_answers.csv", "r", :col_sep => "\t") do |row|
          if answer.include?(row[1])
            event.respond "Answer already exists. Aborting."
            break
          end
        end

        CSV.open("data/ask_rin_answers.csv", "a", :col_sep => "\t") do |csv|
          csv << [answer, event.user.id]
        end
        event.respond "Answer added."
      end
    end
  end
end
