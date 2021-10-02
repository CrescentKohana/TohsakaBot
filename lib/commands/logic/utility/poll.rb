# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Poll
      def initialize(event, question, choices, duration, multi, type, template)
        @event = event
        @question = question.nil? ? I18n.t("commands.utility.poll.default_question") : question.sanitize_string
        @duration = if duration.nil?
                      choices.nil? ? 30 : nil
                    else
                      parse_duration(duration)
                    end

        @multi = multi.nil? ? false : multi
        @type = type ? :emoji : :button # TODO: dropdown type

        parsed = if choices.nil? || !template.nil?
                   template(template, @duration.nil?)
                 else
                   parse_choices(choices, @duration.nil?)
                 end
        @choices = parsed[:choices]
        @choice_chunks = parsed[:choice_chunks]
      end

      def run
        buttons = @type == :button ? create_buttons(@event.user.id) : nil

        {
          content: "#{@question} `Votes: 0`",
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
        is_integer = !Integer(input, exception: false).nil?
        return nil if is_integer && input.to_i.zero?
        return input.to_i.clamp(10, 60 * 60 * 24) if is_integer

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

      def parse_choices(choices, end_button)
        parsed_choices = choices.split(';').take((end_button ? 24 : 25)).map do |choice|
          { content: choice[0..79], type: :choice }
        end

        cloned_choices = parsed_choices.clone
        cloned_choices << { content: "End poll", type: :end } if end_button
        choice_chunks = cloned_choices.each_slice(5).to_a

        { choice_chunks: choice_chunks, choices: parsed_choices }
      end

      def template(type, end_button)
        choices = case type
                  when 'thumb'
                    '👍;👎'
                  when 'numbers'
                    '1;2;3'
                  else # tick
                    '✅;❌'
                  end

        parse_choices(choices, end_button)
      end
    end
  end
end
