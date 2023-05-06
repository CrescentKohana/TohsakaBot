# frozen_string_literal: true

class UsersController < ApplicationController
  def update
    return unless redirect_if_anonymous

    @user = User.find(session[:user_id])
    @user[:locale] = user_params[:locale]
    @user[:birthday] = user_params[:birthday]
    @user[:timezone] = user_params[:timezone]

    flash[:notice] = if @user.update(user_params)
                       "Settings updated!"
                     else
                       "Error on trying to update settings."
                     end
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:locale, :birthday, :timezone)
  end
end
