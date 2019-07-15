module TohsakaBot
  extend Discordrb::Commands::CommandContainer
  bucket :saber, limit: 3, time_span: 3600, delay: 20

end