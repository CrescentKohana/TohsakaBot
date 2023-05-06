# frozen_string_literal: true

module TohsakaBot
  # Methods for Japanese language. Currently mostly pitch accent.
  module JapaneseHelper
    KATAKANA = %w[ァィゥェォヵㇰヶㇱㇲㇳㇴㇵㇶㇷㇷ゚ㇸㇹㇺャュョㇻㇼㇽㇾㇿヮ].freeze
    NHK_JSON = JSON.parse(File.read(CFG.data_dir + '/persistent/nhk_accents/nhk.json')).to_a.map do |a|
      {
        id: a["id"],
        kana: a["kana"],
        kanji: a["kanji"],
        accents: a["accents"]
      }
    end

    def accent_output(word, accent)
      output = ''.dup
      mora = 0
      i = 0

      while i < word.length
        output += word[i]
        i += 1
        mora += 1

        while i < word.length && KATAKANA.include?(word[i])
          output += word[i]
          i += 1
        end

        output += "＼" if mora == accent
      end

      output
    end

    def get_accents(word)
      results = NHK_JSON.select { |a| a[:kana] == word || a[:kanji].include?(word) }
      return results unless results.nil?

      nil
    end

    def construct_response(results)
      response = "".dup
      results.each do |r|
        kana = r[:kana]
        kanji_and_kana = r[:kanji].blank? ? kana : "#{kana}【#{r[:kanji]&.join('、')}】"
        accent = r[:accents][0]["accent"][0]["pitch_accent"]
        drop = accent_output(r[:accents][0]["accent"][0]["pronunciation"], accent)

        response += "#{kanji_and_kana}\n"\
                    "・[［#{accent}］#{drop}](#{CFG.nhk_api}#{r[:accents][0]['sound_file']})\n\n"
      end

      [results.first[:kana], response]
    end
  end

  TohsakaBot.extend JapaneseHelper
end
