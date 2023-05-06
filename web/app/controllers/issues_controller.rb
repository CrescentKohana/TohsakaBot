# frozen_string_literal: true

require 'simple_form'

class IssuesController < ApplicationController
  def index
    return unless redirect_if_anonymous

    servers = servers_with_access_to(:default_channel)
    @issues = Issue.where(server_id: servers).or(Issue.where(user_id: session[:user_id]))

    respond_to do |format|
      format.html
      format.json { render json: @issues }
    end
  end

  def show
    return unless redirect_if_anonymous

    @issue = Issue.find(params[:id])
    return unless redirect_if_no_discord_perms(@issue[:server_id], :default_channel, own?(@issue[:id]))

    respond_to do |format|
      format.html
      format.json { render json: @issue }
    end
  end

  def new
    return unless redirect_if_anonymous

    @issue = Issue.new
  end

  def edit
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @issue = Issue.find(params[:id])
  end

  def create
    return unless redirect_if_anonymous

    @issue = Issue.new(issue_params)
    @issue[:user_id] = user_id

    if @issue.save
      redirect_to @issue
    else
      render 'new'
    end
  end

  def update
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @issue = Issue.find(params[:id])
    return unless @issue[:status] == 'new'

    if @issue.update(issue_params)
      redirect_to @issue
    else
      render 'edit'
    end
  end

  def destroy
    return unless redirect_if_anonymous
    return unless permission?(params[:id])

    @issue = Issue.find(params[:id])
    return unless @issue[:status] == 'new'

    @issue.destroy

    redirect_to issues_path
  end

  private

  def issue_params
    params.require(:issue).permit(:content, :category, :server_id)
  end

  def permission?(issue_id)
    return true if own?(issue_id)

    redirect_to root_path
    false
  end

  def own?(issue_id)
    Issue.find(issue_id)[:user_id] == session[:user_id]
  end

  def category(index)
    %w[Feature Bug][index]
  end

  def status_color(status)
    case status
    when 'done'
      '#00921B'
    when 'wontdo'
      '#BE0000'
    when 'indev'
      '#004A0E'
    else
      '#0070EE'
    end
  end

  def choosable_servers(discord_uid)
    return nil if discord_uid.nil?

    servers = {}
    servers_with_access_to(:default_channel, false).each do |server|
      next if server.nil?

      servers[server[:id]] = server[:data][:name]
    end

    servers
  end

  helper_method :own?,
                :category,
                :status_color,
                :choosable_servers
end
