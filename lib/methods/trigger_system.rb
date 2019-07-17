# TODO: Finish this. At the moment not used. Also clean up other methods too.
class Trigger_system

  @triggers_all = YAML.load_file('data/triggers.yml')

  @trigger_words = []

  # Convert all regex found in the database to a form that Ruby can read,
  # and pass them in to a array which contains only the words that trigger reacts to.
  @triggers_all.each do |key, value|
    @trigger_words << value["trigger"].to_regexp(detect: true)
  end

  attr_reader :trigger_words, :triggers_all
  # def trigger_words
  #  @trigger_words
  # end

  def load_new_trigger(trigger_word:, userid:, response: '', file_name: '')

    trigger_db = YAML::Store.new('data/triggers.yml')

    trigger_db.transaction do
      i = 1
      while triggers.root?(i) do i += 1 end
      trigger_db[i] = {"trigger" => "#{trigger_word}", "reply" => response, "file" => file_name, "user" =>"#{userid}", "chance" =>@chance }
      trigger_db.commit
    end

    @trigger_words << trigger_word.to_regexp(detect: true)
  end

end
