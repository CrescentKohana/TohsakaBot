# frozen_string_literal: true

module TohsakaBot
  module NekosHelper
    def neko_types
      %w[feet yuri trap futanari hololewd lewdkemo solog feetg cum erokemo les wallpaper lewdk ngif
         meow tickle lewd feed gecg eroyuri eron cum_jpg bj nsfw_neko_gif solo kemonomimi nsfw_avatar gasm
         poke anal slap hentai avatar erofeet holo keta blowjob pussy tits holoero lizard pussy_jpg pwankg classic
         kuni waifu pat kiss femdom neko spank cuddle erok fox_girl boobs random_hentai_gif hug ero]
    end

    def neko_txt_types
      %w[fact why cat eight_ball]
    end

    def get_neko(type)
      nekos = NekosLife::Client.new
      nekos.send(type)
    end
  end

  TohsakaBot.extend NekosHelper
end
