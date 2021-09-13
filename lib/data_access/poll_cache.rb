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

      if @polls[id][:multi]
        return I18n.t("events.poll.vote.already_voted_multi") if @polls[id][:choices][choice_id][:votes].include?(user_id)
      else
        @polls[id][:choices].each do |choice|
          return I18n.t("events.poll.vote.already_voted_single") if choice[:votes].include?(user_id)
        end
      end

      @polls[id][:choices][choice_id][:votes].add(user_id)
      I18n.t("events.poll.vote.success", choice: @polls[id][:choices][choice_id][:content])
    end

    # TODO: expire poll message too, probably when voting
    def stop(id, format_result: true)
      results = @polls[id]
      @polls.delete(id)

      return results unless format_result

      construct_results(results)
    end

    # TODO: embed
    def construct_results(results)
      response = "`Votes | Choice               ".dup
      results[:choices].each do |choice|
        response << "\n#{format('%5s', choice[:votes].size)} | #{choice[:content]}"
      end

      "#{response}`"
    end
  end
end
