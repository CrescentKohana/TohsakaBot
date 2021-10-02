# frozen_string_literal: true

module TohsakaBot
  class RPSCache
    attr_accessor :rps

    def initialize
      @rps = {}
      @results = [
        [nil, true, false],
        [false, nil, true],
        [true, false, nil]
      ].freeze
    end

    # @param id Discord message ID
    # @param user_id Discord user ID
    # @param choice 1 (rock), 2 (paper) or 3 (scissors)
    #
    # @return id winner's Discord user ID
    def play(id, user_id, choice)
      added = add_play(id, user_id.to_i, choice)
      return check(id) if !added.nil? && added[:status] == :end

      added
    end

    # @param msg_id Discord message ID
    # @param challenger_id Discord user ID
    # @param challenged_id Discord user ID
    def new_game(msg_id, challenger_id, challenged_id)
      @rps[msg_id] = { challenger: challenger_id, challenged: challenged_id, game: [] }
    end

    private

    # @param id Discord message ID
    # @param user_id Discord user ID
    # @param choice 0 (rock), 1 (paper) or 2 (scissors)
    #
    # @return boolean true if vote succeeded
    def add_play(id, user_id, choice)
      return nil if @rps[id].nil? || @rps[id][:game].size >= 2

      @rps[id][:game].each do |player|
        return { status: :already_picked, content: player[:choice] } if player[:user_id] == user_id
      end

      # If 2 designated players and the pick is not from either player.
      a = !@rps[id][:challenged].nil? && @rps[id][:challenger] != user_id && @rps[id][:challenged] != user_id
      # If 1 designated player and the pick now is not from that (author) player and someone else has already picked.
      b = @rps[id][:game].size == 1 && @rps[id][:challenger] != user_id && @rps[id][:game].none? { |p| p[:user_id] == @rps[id][:challenger] }

      return { status: :in_progress, content: nil } if a || b

      @rps[id][:game] << { user_id: user_id, choice: choice }
      { status: @rps[id][:game].size < 2 ? :success : :end, content: choice }
    end

    def check(id)
      result = @results[@rps[id][:game][0][:choice].to_i][@rps[id][:game][1][:choice]]
      return { status: :tie, content: [@rps[id][:game][0], @rps[id][:game][1]] } if result.nil?

      winner = result ? 1 : 0
      loser = result ? 0 : 1

      tmp = @rps.dup
      @rps.delete(id)
      { status: :win, content: { winner: tmp[id][:game][winner], loser: tmp[id][:game][loser] } }
    end
  end
end
