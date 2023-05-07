# frozen_string_literal: true

require 'open-uri'
require 'nekos'

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

    def saucenao(url)
      snao_url = "http://saucenao.com/search.php?output_type=2&dbmask=32&api_key=#{AUTH.saucenao_apikey}&url=#{url}"
      begin
        api_json = URI.parse(snao_url).open
      rescue OpenURI::HTTPError
        return nil
      end
      response = JSON.parse(api_json.string)

      return nil if response.blank? || response['results'].blank? || response['results'][0]['data']['pixiv_id'].blank?

      response['results'][0]['data']['pixiv_id']
    end
  end

  TohsakaBot.extend NekosHelper
end
