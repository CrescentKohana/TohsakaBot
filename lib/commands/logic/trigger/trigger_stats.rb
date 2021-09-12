# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class TriggerStats
      def initialize(event, sort, mode, proportional_chance, appearance_type)
        @event = event
        @sort = sort ? :ascending : :descending
        @proportional_chance = proportional_chance
        @appearance_type = appearance_type ? :calls : :occurences
        @mode = case mode
                when /e.*/si
                  0
                when /a.*/si
                  1
                when /r.*/si
                  2
                else
                  nil
                end
      end

      def run
        stats = TohsakaBot.trigger_data.statistics(
          sorting: @sort,
          mode: @mode,
          proportional_chance: @proportional_chance,
          appearance_type: @appearance_type
        )

        # TODO: Add at least chance, mode and last_triggered. Also make the format better.
        output = "**Type: #{@appearance_type}**"\
                 "\n```  Count | ID   | Phrase " \
                 "\n===================================================\n".dup

        stats[0..10].each do |t|
          id = t[:id].to_i
          count = t[@appearance_type]
          phrase = t[:phrase]

          output << "#{format('%7s', count)} | #{format('%4s', id)} | #{phrase}\n"
        end

        if stats.any?
          { content: "#{output}```" }
        else
          { content: t("commands.trigger.errors.not_found") }
        end
      end
    end
  end
end
