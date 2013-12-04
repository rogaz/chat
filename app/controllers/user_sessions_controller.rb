class UserSessionsController < ApplicationController

  before_filter :authenticate, :only => [:destroy]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to rooms_path
    else
      flash[:notice] = 'El usuario y la contrasena no coinciden'
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to signin_path
  end
end
