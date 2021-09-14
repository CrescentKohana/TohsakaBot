# frozen_string_literal: true

module TohsakaBot
  class PollCache
    attr_accessor :polls

    def initialize
      @polls = {}
    end

    # id: message_id
    def create(id, channel_id, question, choices, duration, multi)
      # This poll already exists for some reason.
      return nil unless @polls[id].nil?

      @polls[id] = {}
      @polls[id][:channel_id] = channel_id
      @polls[id][:question] = question
      @polls[id][:choices] = choices.map { |c| { content: c[:content], votes: Set.new } }
      @polls[id][:time] = duration.nil? ? nil : Time.now.to_i + duration
      @polls[id][:multi] = multi.nil? ? false : multi

      id
    end

    def vote(id, user_id, choice_id)
      choice_id = choice_id.to_i
      user_id = user_id.to_i

      return I18n.t("events.poll.vote.expiry") if @polls[id].nil? || @polls[id][:choices][choice_id].nil?

      votes = total_votes(@polls[id])

      if @polls[id][:multi]
        return I18n.t("events.poll.vote.already_voted_multi", votes: votes) if @polls[id][:choices][choice_id][:votes].include?(user_id)
      else
        @polls[id][:choices].each do |choice|
          return I18n.t("events.poll.vote.already_voted_single", votes: votes) if choice[:votes].include?(user_id)
        end
      end

      # TODO: only edit message content without buttons disappearing
      # Discordrb::API::Channel.edit_message(
      #   "Bot #{AUTH.bot_token}",
      #   @polls[id][:channel_id],
      #   id,
      #   "`#{total_votes(@polls[id])}` #{@polls[id][:question]}",
      #   false,
      #   nil
      # )

      @polls[id][:choices][choice_id][:votes].add(user_id)
      I18n.t("events.poll.vote.success", choice: @polls[id][:choices][choice_id][:content], votes: votes + 1)
    end

    def total_votes(poll)
      votes = 0
      poll[:choices].each do |choice|
        votes += choice[:votes].size
      end

      votes
    end

    # TODO: expire poll message too, probably when voting
    def stop(id, format_result: true)
      results = @polls[id]
      votes = total_votes(@polls[id])
      @polls.delete(id)

      return results unless format_result

      construct_results(results, votes)
    end

    def construct_results(results, votes)
      results[:choices] = results[:choices].sort_by { |choice| choice[:votes].size }

      choices = ''.dup
      results[:choices].each do |choice|
        choices << "\n#{choice[:content]} | **#{format('%5s', choice[:votes].size)}**"
      end

      builder = Discordrb::Webhooks::Builder.new
      builder.add_embed do |e|
        e.title = results[:question]
        e.colour = 0xE91E53
        e.description = choices
        # results[:choices].each do |choice|
        #   e.add_field(name: choice[:content], value: choice[:votes].size)
        # end
        e.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Total votes: #{votes}")
      end

      builder
    end
  end
end
