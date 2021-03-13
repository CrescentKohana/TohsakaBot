# frozen_string_literal: true

module TohsakaBot
  module Events
    module Squads
      extend Discordrb::EventContainer
      reaction_add(emoji: "✅") do |event|
        next if event.channel.pm? || event.user.bot_account
        next unless Time.now.to_i <= event.message.timestamp.to_i + 3600

        if event.user.id == event.message.author.id
          Discordrb::API::Channel.delete_user_reaction(
            "Bot #{AUTH.bot_token}", event.channel.id, event.message.id, "✅", event.message.author.id
          )
          next
        end

        roles = JSON.parse(File.read("data/persistent/squads.json"))
        role_mentions = {}
        event.message.role_mentions.each do |rm|
          role_mentions[rm.id] = rm.name
        end

        author_id = event.message.author.id.to_i
        reactions = event.message.reactions.map { |r| { r.name => r.count } }
        custom_group_size = event.message.content.sub(/<@&\d*>/, "").first_number

        roles.each_key do |role|
          members = JSON.parse(Discordrb::API::Channel.get_reactions(
                                 "Bot #{AUTH.bot_token}", event.channel.id, event.message.id, "✅", false, false
                               )).reject { |m| m["bot"] || m["id"].to_i == author_id }.map { |m| "<@!#{m['id']}>" }

          reaction_count = reactions[0]["✅"].to_i
          reaction_count -= 1 if members.include? "<@!#{author_id}>"
          group_size = custom_group_size.nil? ? roles[role]["group_size"] : custom_group_size

          next unless role_mentions.key?(roles[role]["role_id"]) && reaction_count >= group_size.to_i

          event.respond "Found squad for **#{role}**: <@!#{author_id}> #{members.join(' ')}"
          event.message.delete
          break
        end
      end
    end
  end
end
