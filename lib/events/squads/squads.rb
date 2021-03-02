module TohsakaBot
  module Events
    module Squads
      extend Discordrb::EventContainer
      reaction_add(emoji: "✅") do |event|
        roles = JSON.parse(File.read("data/persistent/squads.json"))
        role_mentions = {}
        event.message.role_mentions.each do |rm|
          role_mentions[rm.id] = rm.name
        end

        author_id = event.message.author.id.to_i
        reactions = event.message.reactions.map { |r| { r.name => r.count } }
        roles.each_key do |role|
          members = JSON.parse(Discordrb::API::Channel.get_reactions(
            "Bot #{AUTH.bot_token}", event.channel.id, event.message.id, "✅", false, false
          )).reject { |m| m["bot"] || m["id"].to_i == author_id }.map { |m| "<@!#{m["id"]}>" }

          reaction_count = reactions[0]["✅"].to_i - 1
          reaction_count -= 1 if members.include? "<@!#{author_id}>"
          next unless role_mentions.key?(roles[role]["role_id"]) && reaction_count >= roles[role]["group_size"]

          event.respond "Found squad for **#{role}**: <@!#{author_id}> #{members.join(' ')}"
          event.message.delete
          break
        end
      end
    end
  end
end
