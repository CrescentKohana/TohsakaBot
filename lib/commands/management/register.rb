module TohsakaBot
  module Commands
    module Register
      extend Discordrb::Commands::CommandContainer
      command(:register,
              description: 'Registers user to database.') do |event|

        author = event.author

        users = TohsakaBot.db[:users]
        auths = TohsakaBot.db[:authorizations]

        if !auths.where(:uid => author.id).empty?
          event.<< "You've already been registered!"
        else
          TohsakaBot.db.transaction do
            user_id = users.insert(name: author.name,
                                discriminator: author.discriminator,
                                avatar: author.avatar_id,
                                locale: "",
                                created_at: Time.now,
                                updated_at: Time.now)

            auths.insert(provider: 'discord',
                         uid: author.id,
                         user_id: user_id,
                         created_at: Time.now,
                         updated_at: Time.now)
          end
          event.<< "You've been successfully registered!"
        end
      end
    end
  end
end
