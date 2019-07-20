module TohsakaBot
  module Commands
    module RemindMe
      extend Discordrb::Commands::CommandContainer
      command(:remindme,
              aliases: %i[remind remadd remind addrem muistuta rem],
              description: 'Reminder.',
              min_args: 1,
              usage: 'remindme <R01y01M01w01d01h01m01s||yyyy-MM-dd_hh:mm:ss> <msg> (R for repeated, >10 minutes)',
              rescue: "Something went wrong!\n`%exception%`") do |event, timei, *msg|

        duration_regex = /^[ydwhmseckin0-9-]*$/i
        date_regex = /^[0-9]{4}-(1[0-2]|0[1-9])-(3[0-2]|[1-2][0-9]|0[1-9])\s(2[0-4]|1[0-9]|0[0-9]):(60|[0-5][0-9]):(60|[0-5][0-9])/
        userid = event.message.user.id
        channelid = event.channel.id
        fmsg = msg.join(' ').strip_mass_mentions.sanitize_string

        # Messages #
        error_reminder_limit = "Sorry, but the the limit for remainders per user is #{$settings['remainder_limit']}! Wait that they expire or remove them with `reminders` & `delreminder <id(s)>`."
        error_negative = 'The thing is.. time travel is still a little hard for me :( so try not to use negative values. Syntax: Usage: `remindme <R01y01M01w01d01h01m01s||yyyy-MM-dd_hh:mm:ss> <msg> (R for repeated, >10 minutes)`'
        error_time_travel = 'The thing is.. time travel is still a little hard for me :( so try not to use past dates. Usage: `remindme <R01y01M01w01d01h01m01s||yyyy-MM-dd_hh:mm:ss> <msg> (R for repeated, >10 minutes)`'

        def self.matchtime(time, regex)
          if time.match(regex)
            time.scan(regex)[0][0]
          end
        end

        def self.userlimit_calc(filepath)
          limit = YAML.load_file(filepath)
          @limit_array = []

          limit.each do |key, value|
            uid = value["user"]
            @limit_array << uid.to_i
          end
        end

        def self.userlimit_check(larray, ui)
          larray.count(ui.to_i) <= $settings['remainder_limit'].to_i
        end

        def self.store_reminder(time_format, time_confirm, ev, fm, ui, ci, m, r)
          remind_db = YAML::Store.new('data/reminders.yml')
          repeated_msg = r != "false" ? "repeatedly " : ""
          # TODO: Convert seconds to a better format.
          repetition_interval = r != "false" ? " Interval #{r}s." : ""

          remind_db.transaction do
            i = 1
            while remind_db.root?(i) do i += 1 end
            remind_db[i] = {"time" => time_format, "message" => "#{fm}", "user" => "#{ui}", "channel" =>"#{ci}", "repeat" =>"#{r}" }
            remind_db.commit
          end

          if m.empty?
            ev.respond("I shall #{repeated_msg}remind <@#{ui.to_i}> at `#{time_confirm}`.#{repetition_interval}")
          else
            ev.respond("I shall #{repeated_msg}remind <@#{ui.to_i}> with #{fm.hide_link_preview} at `#{time_confirm}`.#{repetition_interval}")
          end

          unless ev.channel.pm?
            ev.message.delete
          end
        end

        # If the reminder is to be repeated.
         if timei[0] != 'R' && timei[0] != 'r'
           repeat = 'false'
         else
           repeat = ''
           timei[0] = ''
         end

        if duration_regex.match?(timei.to_s)

          # Format P(n)Y(n)M(n)W(n)DT(n)H(n)M(n)S
          seconds = matchtime(timei, /([0-9]*)(sec|sek|[sS])/) || 0
          minutes = matchtime(timei, /([0-9]*)(min|[m])/) || 0
          hours = matchtime(timei, /([0-9]*)([hH])/) || 0
          days = matchtime(timei, /([0-9]*)([dD])/) || 0
          weeks = matchtime(timei, /([0-9]*)([wW])/) || 0
          months = matchtime(timei, /([0-9]*)([M])/) || 0
          years = matchtime(timei, /([0-9]*)([yYa])/) || 0

          if weeks == 0
            iso8601time = if "#{hours}#{minutes}#{seconds}".to_s.empty?
                            "P#{years}Y#{months}M#{days}D"
                          else
                            "P#{years}Y#{months}M#{days}DT#{hours}H#{minutes}M#{seconds}S"
                          end
          else
            if "#{years}#{months}#{days}".to_s.empty?
              iso8601time = if "#{hours}#{minutes}#{seconds}".to_s.empty?
                              "P#{weeks}W"
                            else
                              "P#{weeks}WT#{hours}H#{minutes}M#{seconds}S"
                            end
            else
              event.respond("Mixing weeks with other date parts (y, M, d) is not allowed.")
              break
            end
          end

          parsed = ActiveSupport::Duration.parse(iso8601time)

          if repeat != 'false'
            repeat = parsed.seconds
            if parsed.seconds.to_i < 600
              event.respond('The interval limit for repeated reminders is ten minutes. Reminder aborted.')
              break
            end
          end

          if parsed.seconds.from_now > Time.now && date_regex.match?(parsed.seconds.from_now.to_s)
            userlimit_calc('data/reminders.yml')

            if userlimit_check(@limit_array, @userid)
              store_reminder(parsed.seconds.from_now.to_i, parsed.seconds.from_now, event, fmsg, userid, channelid, msg, repeat)
            else
              event.respond(error_reminder_limit)
            end
          else
            event.respond(error_negative)
          end

        elsif date_regex.match?("#{timei.gsub('_', ' ')} #{msg}")
          datetime = "#{timei.gsub('_', ' ')}"

          if Time.parse(datetime).to_i > Time.now.to_i && date_regex.match?(datetime.to_s)
            userlimit_calc('data/reminders.yml')
            if userlimit_check(@limit_array, @userid)
              store_reminder(Time.parse(datetime).to_i, datetime, event, fmsg, userid, channelid, msg, 'false')
            else
              event.respond(error_reminder_limit)
            end
          else
            event.respond(error_time_travel)
          end

        else
          event.respond('Usage: `remindme <R01y01M01w01d01h01m01s||yyyy-MM-dd_hh:mm:ss> <msg> (R for repeated, >10 minutes)`')
        end
      end
    end
  end
end
