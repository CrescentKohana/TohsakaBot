module TohsakaBot
  module Events
    module SquadsHelper
      extend Discordrb::EventContainer
      roles = JSON.parse(File.read('data/persistent/squads.json')).map { |r| /.*<@&#{r[1]["role_id"]}>.*/ }
      message(content: roles) do |event|
        event.message.create_reaction('✅')
        event.message.create_reaction('❌')
      end
    end
  end
end
