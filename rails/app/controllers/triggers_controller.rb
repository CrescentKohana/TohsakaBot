# frozen_string_literal: true

require 'simple_form'

class TriggersController < ApplicationController
  before_action :tohsakabot_online

  def index
    return unless redirect_if_anonymous

    @triggers = Trigger.where(user_id: user_id)

    respond_to do |format|
      format.html
      format.json { render json: @triggers }
    end
  end

  def show
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @trigger = Trigger.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @trigger }
    end
  end

  def new
    return unless redirect_if_anonymous

    @trigger = Trigger.new
  end

  def edit
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @trigger = Trigger.find(params[:id])
  end

  def create
    return unless redirect_if_anonymous

    @trigger = Trigger.new(trigger_params)
    @trigger.user_id = user_id
    @trigger.chance = 0 if permissions?(100)

    if @trigger.save
      # Pass the file to TohsakaBot if there's one
      tohsaka_bridge.save_trigger_file(@trigger.file.current_path, @trigger.file.filename) if @trigger.reply.blank?
      tohsaka_bridge.reload_triggers
      redirect_to @trigger
    else
      render 'new'
    end
  end

  def update
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @trigger = Trigger.find(params[:id])
    file = @trigger[:file]
    new_file = false
    new_reply = false

    if trigger_params[:file].blank? && !trigger_params[:reply].blank?
      @trigger[:file] = ""
      new_reply = true
    elsif trigger_params[:reply].blank? && !trigger_params[:file].blank?
      @trigger[:reply] = ""
      new_file = true
    end

    # Permissions of 100 required to change the chance
    trigger_params_with_chance = trigger_params
    trigger_params_with_chance[:chance] = @trigger[:chance] unless permissions?(100)

    if @trigger.update(trigger_params_with_chance)
      # If there is a new file, save it.
      tohsaka_bridge.save_trigger_file(@trigger.file.current_path, @trigger.file.filename) if new_file
      # If there is (a new file OR a reply) AND there is a previous file, remove the previous file.
      File.delete(Rails.configuration.data_dir + "/triggers/#{file}") if (new_file || new_reply) && !file.blank?

      tohsaka_bridge.reload_triggers
      redirect_to @trigger
    else
      render 'edit'
    end
  end

  def destroy
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @trigger = Trigger.find(params[:id])
    file = @trigger[:file]
    File.delete(Rails.configuration.data_dir + "/triggers/#{file}") if @trigger.destroy && !file.blank?

    tohsaka_bridge.reload_triggers
    redirect_to triggers_path
  end

  private

  def trigger_params
    params.require(:trigger).permit(:phrase, :reply, :server_id, :mode, :file, :chance)
  end

  def upload_file(file)
    return if file.nil?

    # Returns the new name while moving it to triggers folder inside TohsakaBot
    tohsaka_bridge.save_trigger_file(file)
  end

  def permission?(trigger_id)
    return true if Trigger.find(trigger_id)[:user_id] == session[:user_id]

    redirect_to root_path
    false
  end

  def choosable_servers(discord_uid)
    return nil if discord_uid.nil?

    possible_servers = {}
    tohsaka_bridge.servers_user_is_in(discord_uid).each do |c|
      possible_servers[c.id] = c.name
    end

    possible_servers
  end

  def mode_in_words(mode_id)
    case mode_id.to_i
    when 1
      "any"
    when 2
      "regex"
    else
      "exact"
    end
  end

  helper_method :choosable_servers, :mode_in_words
end
