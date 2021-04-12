# frozen_string_literal: true

module TohsakaBot
  module NekosHelper
    def neko_types(nsfw: true)
      nsfw_tags = %w[feet yuri trap futanari hololewd lewdkemo solog feetg cum erokemo les lewdk ngif
                     lewd gecg eroyuri eron cum_jpg bj nsfw_neko_gif solo kemonomimi nsfw_avatar gasm
                     anal slap hentai avatar erofeet holo keta blowjob pussy tits holoero pussy_jpg pwankg classic
                     kuni waifu pat kiss femdom spank cuddle erok fox_girl boobs random_hentai_gif ero]
      sfw_tags =  %w[wallpaper meow tickle feed poke lizard pat neko hug]

      return nsfw_tags + sfw_tags if nsfw

      sfw_tags
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
