# frozen_string_literal: true

module TohsakaBot
  module Events
    module Squads
      extend Discordrb::EventContainer
      reaction_add(emoji: "✅") do |event|
        next if event.channel.pm? || event.user.bot_account
        next if event.message.content&.first == '#'
        next if event.message.role_mentions.empty?

        if Time.now.to_i >= event.message.timestamp.to_i + 3600
          event.message.delete_all_reactions
          event.message.create_reaction('🔄')
          next
        end

        if event.user.id == event.message.author.id
          Discordrb::API::Channel.delete_user_reaction(
            "Bot #{AUTH.bot_token}", event.channel.id, event.message.id, "✅", event.message.author.id
          )
          next
        end

        roles = TohsakaBot.role_cache[event.server.id][:roles]
        role_mentions = Set.new
        event.message.role_mentions.each do | rm|
          role_mentions.add(rm.id)
        end

        author_id = event.message.author.id.to_i
        custom_group_size = event.message.content.split(/<@&\d*>/)[0].to_i
        members = JSON.parse(
          Discordrb::API::Channel.get_reactions(
            "Bot #{AUTH.bot_token}",
            event.channel.id,
            event.message.id,
            "✅",
            nil,
            nil
          )
        ).reject { |m| m["bot"] }.map { |m| "<@!#{m['id']}>" } # Reject the bot.

        # Members size has to be saved before removing the possible appearance of the message author.
        reaction_count = members.size
        members.delete("<@!#{author_id}>")

        role_mentions.each do |rm|
          next unless roles[rm]

          group_size = custom_group_size.nil? || custom_group_size < 1 ? roles[rm][:group_size] - 1 : custom_group_size
          next unless group_size == reaction_count

          event.respond "Found squad for **#{roles[rm][:name]}**: <@!#{author_id}> #{members.join(' ')}"
          event.message.delete
          break
        end
      end
    end
  end
end
