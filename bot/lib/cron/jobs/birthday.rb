module TohsakaBot
  module Jobs
    def self.birthday(now)
      users = TohsakaBot.db[:users]
      users_with_birthdays = users.where(Sequel[:last_congratulation] < now.year).all
      return if users_with_birthdays.empty?

      users_with_birthdays = users_with_birthdays.filter { |u| Time.at(u[:birthday]).change(year: now.year) < now }
      return if users_with_birthdays.empty?

      message = '🎉 Happy birthday 🎉 to '.dup
      users_with_birthdays.each do |user|
        discord_uid = TohsakaBot.get_discord_id(user[:id])
        message << "<@#{discord_uid}> "
      end

      # Looping users for second time as we want to make sure that the message was sent
      # before the last_congratulation is updated for good.
      BOT.channel(CFG.default_channel)&.send_message(message)
      TohsakaBot.db.transaction do
        users_with_birthdays.each do |user|
          users.where(id: user[:id]).update(last_congratulation: now.year)
        end
      end
    end
  end
end
