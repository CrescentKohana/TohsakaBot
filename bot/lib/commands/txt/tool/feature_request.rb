# frozen_string_literal: true

module TohsakaBot
  module Commands
    module FeatureRequest
      extend Discordrb::Commands::CommandContainer

      command(:featurerequest,
              aliases: TohsakaBot.get_command_aliases('commands.tool.feature.request.aliases'),
              description: I18n.t(:'commands.tool.feature.request.description'),
              usage: I18n.t(:'commands.tool.feature.request.usage'),
              min_args: 1,
              require_register: true,
              enabled_in_pm: false) do |event, *msg|
        # if TohsakaBot.user_limit_reached?(event.author.id, 1000, :triggers)
        #   event.respond 'The maximum amount of feature requests a user can have is 1000. '
        #   break
        # end

        content = msg.join(' ').strip
        issues = TohsakaBot.db[:issues]
        TohsakaBot.db.transaction do
          @id = issues.insert(
            content: content,
            category: 0,
            status: 'new',
            user_id: TohsakaBot.get_user_id(event.message.user.id),
            server_id: event.server.id,
            created_at: TohsakaBot.time_now,
            updated_at: TohsakaBot.time_now
          )
        end

        event.respond("Request saved `<ID: #{@id}>`.")
      end

      command(:findfeaturerequests,
              aliases: TohsakaBot.get_command_aliases('commands.tool.feature.find.aliases'),
              description: I18n.t(:'commands.tool.feature.find.description'),
              usage: I18n.t(:'commands.tool.feature.find.usage'),
              min_args: 1,
              require_register: true) do |event, status|
        header = "`  ID | CREATED    | BY                               | TAGS `\n".dup
        output = ''.dup
        issues = if status == "all"
                   TohsakaBot.db[:issues].order(:created_at)
                 else
                   TohsakaBot.db[:issues].order(:created_at).where(status: status)
                 end

        issues.each do |issue|
          datetime = Time.at(issue[:created_at]).to_s.split(' ')[0]
          username = BOT.user(TohsakaBot.get_discord_id(issue[:user_id])).username
          output << "`#{format('%4s', issue[:id])} | #{datetime} |"\
                    " #{format('%-32s', username)} | #{issue[:status]}`\n`\t\tREQ:` #{issue[:content]}\n"
        end

        where = issues.count > 5 ? event.author.pm : event.channel
        msgs = []
        if issues.count.positive?
          header << output
          msgs = TohsakaBot.send_multiple_msgs(Discordrb.split_message(header), where)
        else
          msgs << event.respond('No requests found.')
        end

        TohsakaBot.expire_msg(where, msgs, event.message)
        break
      end

      command(:tagfeaturerequest,
              aliases: TohsakaBot.get_command_aliases('commands.tool.feature.tag.aliases'),
              description: I18n.t(:'commands.tool.feature.tag.description'),
              usage: I18n.t(:'commands.tool.feature.tag.usage'),
              min_args: 2,
              require_register: true,
              permission_level: TohsakaBot.permissions.actions["feature_requests"]) do |event, id, status|
        issues = TohsakaBot.db[:issues]
        issue = issues.where(id: id.to_i).single_record!

        if issue.nil?
          event.<< "No feature request with an ID of `#{id}` found."
        else
          msg = case status
                when "done"
                  "is done!\n`#{issue[:content]}`"
                when "indev"
                  "is in development!\n`#{issue[:content]}`"
                when "wontdo"
                  "was declined: `#{issue[:content]}`"
                else
                  break
                end
          break if msg.nil?

          issue[:status] = status

          TohsakaBot.db.transaction do
            issues.where(id: id.to_i).update(issue)
          end

          # TODO: cross-server support
          event.<< "Feature request `#{id}` updated!" unless event.channel.id.to_i == CFG.default_channel.to_i

          username = "by <@!#{TohsakaBot.get_discord_id(issue[:user_id])}>"
          # TODO: cross-server support
          BOT.channel(CFG.default_channel.to_i).send_message("Feature request `#{id}` #{username} #{msg}")
        end
      end
    end
  end
end
