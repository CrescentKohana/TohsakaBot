# frozen_string_literal: true

require 'simple_form'

class RemindersController < ApplicationController
  before_action :tohsakabot_online

  def index
    return unless redirect_if_anonymous

    @reminders = Reminder.where(user_id: user_id)

    respond_to do |format|
      format.html
      format.json { render json: @reminders }
    end
  end

  def show
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @reminder }
    end
  end

  def new
    return unless redirect_if_anonymous

    @reminder = Reminder.new
  end

  def edit
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @reminder = Reminder.find(params[:id])
    duration = @reminder[:repeat]
    return unless duration.to_i.positive?

    @reminder.repeat_min = minutes = (duration / 60) % 60
    @reminder.repeat_hour = hours = duration % (60 * 60)
    @reminder.repeat_day = (duration - minutes - hours) / (60 * 60 * 24)
  end

  def create
    return unless redirect_if_anonymous

    @reminder = Reminder.new(reminder_params)
    @reminder[:user_id] = user_id

    days = reminder_params[:repeat_day].to_i
    hours = reminder_params[:repeat_hour].to_i
    minutes = reminder_params[:repeat_min].to_i
    @reminder[:repeat] = (minutes * 60) + (hours * 60 * 60) + (days * 24 * 60 * 60)

    if @reminder.save
      redirect_to @reminder
    else
      render 'new'
    end
  end

  def update
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @reminder = Reminder.find(params[:id])

    days = reminder_params[:repeat_day].to_i
    hours = reminder_params[:repeat_hour].to_i
    minutes = reminder_params[:repeat_min].to_i
    new_repeat = (minutes * 60) + (hours * 60 * 60) + (days * 24 * 60 * 60)
    @reminder[:repeat] = new_repeat

    if @reminder.update(reminder_params)
      redirect_to @reminder
    else
      render 'edit'
    end
  end

  def destroy
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    redirect_to reminders_path
  end

  private

  def reminder_params
    params.require(:reminder).permit(:datetime, :message, :channel_id, :repeat, :repeat_day, :repeat_hour, :repeat_min)
  end

  def permission?(reminder_id)
    return true if Reminder.find(reminder_id)[:user_id] == session[:user_id]

    redirect_to root_path
    false
  end

  def choosable_channels(discord_uid)
    return nil if discord_uid.nil?

    possible_channels = {}
    tohsaka_bridge.channels_user_has_rights_to(discord_uid).each do |c|
      possible_channels[c.id] = tohsaka_bridge.is_pm?(c.id) ? "#Private Message Channel" : c.name
    end

    possible_channels
  end

  def channel_name(reminder)
    return "Deleted channel" if reminder.channel_id.nil? || reminder.channel_id.zero?
    return "Deleted channel" if tohsaka_bridge.get_channel(reminder.channel_id).nil?

    tohsaka_bridge.get_channel(reminder.channel_id).name
  end

  helper_method :choosable_channels,
                :channel_name
end
