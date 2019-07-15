module TohsakaBot
  module Commands
    Dir["#{File.dirname(__FILE__)}/commands/*/*.rb"].each { |file| require file }

    @commands = [Eval, Help, Ping, Information, RoleAdd, RoleDel, Summon,
                 RemindMe, Tester, NowPlaying, Alko, Alkolist, Chaos,
                 Coinflip, Reminders, ReminderDel, Reboot,
                 TriggerAdd, TriggerDel, Triggers, ExclusionUrl,
                 Doubles, Triples, Quads, Stars, Spoiler, EncodeMsg,
                 RegardsKELA, Quickie, GetSauce, Winner, Loser, EmojiList, Number]

    def self.include!
      @commands.each do |event|
        TohsakaBot::BOT.include!(event)
      end
    end
  end
end