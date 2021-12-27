# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    begin
      auth_hash = request.env['omniauth.auth']

      @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      if @authorization
        user = User.find(@authorization.user.id)
        user.update(
          name: auth_hash["extra"]["raw_info"]["username"],
          discriminator: auth_hash["extra"]["raw_info"]["discriminator"],
          avatar: auth_hash["extra"]["raw_info"]["avatar"]
        )

        session[:user_id] = @authorization.user.id
        session[:uid] = @authorization.uid
        session[:name] = @authorization.user.name
        session[:discriminator] = @authorization.user.discriminator
        session[:avatar] = @authorization.user.avatar
        session[:locale] = @authorization.user.locale
        session[:permissions] = @authorization.user.permissions

        flash[:notice] = "You've already signed up. Welcome back #{@authorization.user.name}!"
      else
        unless tohsaka_bridge.share_server_with_bot?(auth_hash["uid"])
          flash[:warning] = "This Discord account doesn't share any servers with the host bot."
          redirect_to root_path
          return
        end

        user = User.new name: auth_hash["extra"]["raw_info"]["username"],
                        discriminator: auth_hash["extra"]["raw_info"]["discriminator"],
                        avatar: auth_hash["extra"]["raw_info"]["avatar"],
                        locale: auth_hash["extra"]["raw_info"]["locale"]

        user.authorizations.build provider: auth_hash["provider"], uid: auth_hash["uid"]
        user.save

        session[:user_id] = user.id
        session[:uid] = auth_hash["uid"]
        session[:name] = user.name
        session[:discriminator] = user.discriminator
        session[:avatar] = user.avatar
        session[:locale] = user.locale
        session[:permissions] = 0

        flash[:notice] = "Welcome #{user.name}! You've signed up."
      end
    rescue StandardError
      flash[:warning] = "There was an error while trying to authenticate you..."
    end
    redirect_to root_path
  end

  def failure
    session[:user_id] = nil
    flash[:error] = "Sorry, but you didn't allow access to TohsakaWeb!"
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You've logged out!"
    redirect_to root_path
  end
end
