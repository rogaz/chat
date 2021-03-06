# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate

  helper_method :current_user_session, :current_user

  protected
  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= current_user_session && current_user_session.user
  end

  def authenticate
    unless current_user
      flash[:notice] = 'No ha iniciado sesión'
      redirect_to signin_path
      false
    end
  end
end
