# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Poll
      def initialize(event, question, choices, duration, multi, type)
        @event = event
        @question = question.strip_mass_mentions.sanitize_string
        @duration = parse_duration(duration)
        @multi = multi

        # TODO: also dropdown type
        @type = type ? :emoji : :button

        # 25 buttons when no End poll button
        @choices = choices.split(';').take((@duration.nil? ? 24 : 25)).map do |choice|
          { content: choice[0..79], type: :choice }
        end

        choices = @choices.clone
        choices << { content: "End poll", type: :end } if @duration.nil?
        @choice_chunks = choices.each_slice(5).to_a
      end

      def run
        buttons = @type == :button ? create_buttons(@event.user.id) : nil

        # TODO: handle duration
        # duration =

        {
          content: @question,
          components: buttons,
          poll_data: {
            question: @question,
            choices: @choices,
            multi: @multi,
            duration: @duration
          }
        }
      end

      def emoji_type(question)
        { content: question, components: nil }
      end

      def create_buttons(author_id)
        i = 0
        Discordrb::Components::View.new do |v|
          @choice_chunks.each do |choices|
            v.row do |r|
              choices.each do |c|
                r.button(style: :primary, label: c[:content], custom_id: "choice#{i}:#{c[:content]}") if c[:type] == :choice
                r.button(style: :success, label: c[:content], custom_id: "poll#{author_id}:end") if c[:type] == :end
                i += 1
              end
            end
          end
        end
      end

      def parse_duration(input)
        return input.to_i.clamp(10, 60 * 60 * 24) unless Integer(input, exception: false).nil?

        seconds = TohsakaBot.match_time(input, /([0-9]*)(sec|sek|[sS])/) || 0
        minutes = TohsakaBot.match_time(input, /([0-9]*)(min|[mM])/) || 0
        hours   = TohsakaBot.match_time(input, /([0-9]*)([hH])/) || 0

        begin
          final_seconds = ActiveSupport::Duration.parse("PT#{hours}H#{minutes}M#{seconds}S")
          final_seconds.zero? ? nil : final_seconds.clamp(10, 60 * 60 * 24)
        rescue ActiveSupport::Duration::ISO8601Parser::ParsingError
          nil
        end
      end
    end
  end
end
