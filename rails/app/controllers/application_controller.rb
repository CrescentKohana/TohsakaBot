# frozen_string_literal: true

require 'drb/drb'
require 'faraday'

class ApplicationController < ActionController::Base
  def api
    return unless redirect_if_anonymous

    render "/api"
  end

  def settings
    return unless redirect_if_anonymous

    @user = User.find(session[:user_id])
    @authorization = Authorization.find_by_user_id(session[:user_id])
    render "/settings"
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  private

  def tohsaka_bridge
    connection = DRbObject.new_with_uri(SERVER_URI)
    connection if connection.online?
  rescue StandardError
    :offline
  end

  def tohsakabot_online(home = false)
    if tohsaka_bridge == :offline
      redirect_to root_path unless home
      return false
    end
    true
  end

  def avatar_url(discord_id, avatar_hash)
    return '/tohsakaweb_default_avatar.png' if discord_id.nil? || avatar_hash.nil?

    base_url = "https://cdn.discordapp.com/avatars/#{discord_id}/#{avatar_hash}."

    return "#{base_url}gif" if avatar_hash[0..1] == 'a_'
    return "#{base_url}png" if Faraday.head("#{base_url}png").status == 200
    return "#{base_url}jpg" if Faraday.head("#{base_url}jpg").status == 200

    '/tohsakaweb_default_avatar.png'
  end

  def user_name
    User.find_by(id: session[:user_id]).name
  end

  def discriminator
    User.find_by(id: session[:user_id]).discriminator
  end

  def discord_id
    session[:uid]
  end

  def user_id
    session[:user_id]
  end

  def avatar_hash
    User.find_by(id: session[:user_id]).avatar
  end

  def locale
    User.find_by(id: session[:user_id]).locale
  end

  def owner?
    Rails.configuration.owner_id == discord_id
  end

  def permissions?(level)
    session[:permissions].to_i >= level.to_i
  end

  def decoded_token
    return unless auth_header

    token = auth_header.split(' ')[1]
    begin
      data = JWT.decode(token, Rails.application.credentials[:jwt_secret], true, algorithm: 'HS256')
      authorization = Authorization.find_by_user_id(data[0]["user_id"])

      session[:user_id] = authorization.user_id
      session[:uid] = authorization.uid
      session[:name] = authorization.user.name
      session[:discriminator] = authorization.user.discriminator
      session[:avatar] = authorization.user.avatar
      session[:locale] = authorization.user.locale
      session[:permissions] = authorization.user.permissions

      data
    rescue JWT::DecodeError
      nil
    end
  end

  def logged_in?
    decoded = decoded_token
    if decoded
      @current_user ||= User.find(decoded[0]['user_id'].to_i)
    elsif session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      false
    end
  end

  def api?
    request.path[0..3] == '/api'
  end

  def redirect_if_anonymous
    unless logged_in?
      if api?
        render json: { message: 'Unauthorized' }, status: :unauthorized
      else
        redirect_to root_path
      end
      return false
    end
    true
  end

  def redirect_if_no_discord_perms(server_id, channel, or_condition = false)
    server = tohsaka_bridge.get_server_config(server_id)
    return true if or_condition || !server.nil? && channel_permission?(server_id, server[channel])

    if api?
      render json: { message: 'Unauthorized' }, status: :unauthorized
    else
      redirect_to root_path
    end
    false
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.application.credentials[:jwt_secret], 'HS256')
  end

  def channel_permission?(server_id, channel_id)
    tohsaka_bridge.channel_permission?(server_id, channel_id, discord_id, :read_messages)
  end

  def servers_with_access_to(channel, id_only = true)
    tohsaka_bridge.get_server_config.map do |server_id, server|
      if channel_permission?(server_id, server[channel])
        id_only ? server_id : { id: server_id, data: server }
      end
    end
  end

  helper_method :api?,
                :tohsaka_bridge,
                :tohsakabot_online,
                :avatar_url,
                :user_name,
                :discriminator,
                :avatar_hash,
                :discord_id,
                :user_id,
                :locale,
                :logged_in?,
                :permissions?,
                :owner?,
                :redirect_if_anonymous,
                :encode_token,
                :channel_permission?,
                :channel_based_server_access
end
