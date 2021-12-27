# frozen_string_literal: true

class TrophiesController < ApplicationController
  before_action :tohsakabot_online

  def index
    return unless redirect_if_anonymous

    servers = servers_with_access_to(:default_channel)
    @trophies = Trophy.where(server_id: servers)

    respond_to do |format|
      format.html
      format.json { render json: @trophies }
    end
  end

  def show
    return unless redirect_if_anonymous

    @trophy = Trophy.find(params[:id])
    return unless redirect_if_no_discord_perms(@trophy[:server_id], :default_channel)

    respond_to do |format|
      format.html
      format.json { render json: @trophy }
    end
  end

  private

  def category(index)
    { role: %w[Unknown Winner Fool][index], color: %w[#000 #00921B #BE0000][index] }
  end

  helper_method :category
end
