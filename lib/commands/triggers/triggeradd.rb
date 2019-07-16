module TohsakaBot
  module Commands
    module TriggerAdd
      extend Discordrb::Commands::CommandContainer
      command(:triggeradd,
              aliases: %i[addtrigger trigger],
              description: 'Adds a triggers.',
              usage: 'addtrigger <regex: y/n> <trigger word>',
              min_args: 2,
              rescue: "Something went wrong!\n`%exception%`") do |event, r, *trigger_string|

        userid = event.message.user.id
        limit = YAML.load_file('data/triggers.yml')
        @limit_array = []

        trigger_word = trigger_string.join(' ')

        def self.write_changes_to_triggers(mod_trg_word:, userid:, response: '', file_name: '')
          triggers = YAML::Store.new('data/triggers.yml')
          triggers.transaction do
            i = 1
            while triggers.root?(i) do i += 1 end
            triggers[i] = {"trigger" => "#{mod_trg_word}", "reply" => response, "file" => file_name, "user" =>"#{userid}", "chance" =>@chance }
            triggers.commit
          end
        end

        def self.download_answer_picture(file, userid, mod_trg_word)
          if /https:\/\/cdn.discordapp.com.*/.match?(file.url)
            if File.file?("triggers/#{file.filename}")
              # if file is already present in the folder, generate a new name
              extension = File.extname(file.filename)
              o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
              string = (0...16).map { o[rand(o.length)] }.join
              file_name = string + extension
            else
              file_name = file.filename
            end
            IO.copy_stream(open(file.url), "triggers/#{file_name}")
          end

          write_changes_to_triggers(mod_trg_word: mod_trg_word, userid: userid, response: '', file_name: "triggers/#{file_name}")
        end

        unless userid.to_i == $config['owner_id'].to_i
          limit.each do |key, value|
            uid = value["user"]
            t = value["trigger"]
            @limit_array << uid.to_i

            if @limit_array.count(userid.to_i) > $settings['trigger_limit'].to_i
              event.respond("Sorry, but the limit for triggers per user is #{$settings['trigger_limit']}!")
              break
            elsif t == trigger_word.to_regexp(detect: true)
              event.respond('Sorry, but the trigger already exists!')
              break
            end
          end
        end

        if r == 'y'
          modified_trigger_word = '/.*\b' + trigger_word.to_s + '\b.*/i'
          @chance = ''
        else
          modified_trigger_word = trigger_word
          @chance = '8'
        end


        if !event.message.attachments.first.nil?
          file = event.message.attachments.first
          download_answer_picture(file, userid, modified_trigger_word)

        else
          event.respond('Tell me the response (5s remaining).')
          response = event.message.await!(timeout: 5)

          if !response.message.attachments.first.nil?
            file = response.message.attachments.first
            download_answer_picture(file, userid, modified_trigger_word)

          elsif response
            write_changes_to_triggers(mod_trg_word: modified_trigger_word, userid: userid, response: response.message.content)

          else
            event.respond('You took too long!')
            break

          end
        end

        $triggers_only << trigger_word.to_regexp(detect: true)
        $triggers = YAML.load_file('data/triggers.yml')
        event.<< 'Trigger added.'
      end
    end
  end
end
