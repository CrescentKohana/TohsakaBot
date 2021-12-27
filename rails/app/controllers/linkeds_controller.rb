# frozen_string_literal: true

class LinkedsController < ApplicationController
  before_action :tohsakabot_online

  def index
    return unless redirect_if_anonymous

    unless params[:q].nil?
      search
      return
    end

    @linkeds = Linked.where(channel_id: tohsaka_bridge.channels_user_has_rights_to(discord_id).map(&:id))

    respond_to do |format|
      format.html
      format.json { render json: @linkeds }
    end
  end

  def show
    return unless redirect_if_anonymous

    @linked = Linked.find(params[:id])

    unless tohsaka_bridge.channels_user_has_rights_to(discord_id).map(&:id).include?(@linked[:channel_id])
      head :not_found
      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @linked }
    end
  end

  def search
    @linkeds = Linked.where(channel_id: tohsaka_bridge.channels_user_has_rights_to(discord_id).map(&:id))
    search_results = LinkedFilter.new.filter(@linkeds, params[:q])
    search_results.to_sql
    search_results.to_a

    render json: search_results
  end
end
