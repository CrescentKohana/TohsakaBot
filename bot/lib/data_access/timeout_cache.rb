# frozen_string_literal: true

module TohsakaBot
  class TimeoutCache
    attr_accessor :timeouts

    def initialize
      @timeouts = {}
    end

    def create(member_id, server_id, channel_id, duration)
      # This timeout poll already exists for some reason.
      return nil unless @timeouts[member_id].nil?

      @timeouts[member_id] = {}
      @timeouts[member_id][:created_at] = Time.now
      @timeouts[member_id][:server_id] = server_id
      @timeouts[member_id][:channel_id] = channel_id
      @timeouts[member_id][:votes] = { yes: Set.new, no: Set.new }
      @timeouts[member_id][:duration] = duration

      member_id
    end

    def vote(member_id, voter_id, choice)
      voter_id = voter_id.to_i
      member_id = member_id.to_i
      return { content: I18n.t("events.timeout.vote.expiry") } if @timeouts[member_id].nil?

      votes = total_votes(member_id)

      if @timeouts[member_id][:votes][:yes].include?(voter_id) || @timeouts[member_id][:votes][:no].include?(voter_id)
        return { content: I18n.t("events.timeout.vote.already_voted", votes: votes) }
      end

      @timeouts[member_id][:votes][choice].add(voter_id)
      votes += 1

      { content: nil, votes: votes }
    end

    def total_votes(member_id)
      @timeouts[member_id][:votes][:yes].size + @timeouts[member_id][:votes][:no].size
    end

    def stop(member_id)
      results = @timeouts[member_id]
      @timeouts.delete(member_id)
      judgement = calc_result(member_id, results)
      return { content: I18n.t(:'commands.tool.admin.timeout.invalid_member') } if judgement.nil?

      if judgement[:success]
        return {
          content: I18n.t(
            "events.timeout.success",
            yes: results[:votes][:yes].size,
            no: results[:votes][:no].size,
            name: judgement[:member],
            duration: results[:duration]
          )
        }
      end

      BOT.send_message(
        results[:channel_id],
        I18n.t("events.timeout.vote.unsuccessful",
               yes: results[:votes][:yes].size,
               no: results[:votes][:no].size,
               name: judgement[:member].display_name)
      )
    end

    def calc_result(member_id, results)
      member = BOT.member(results[:server_id], member_id)
      return nil if member.nil?

      if ([:votes][:yes].size - results[:votes][:no].size) > 2
        member.timeout = Time.at(results[:created_at].to_i + results[:duration])
        return { judgement: true, member: member }
      end

      { success: false, member: member }
    end
  end
end
