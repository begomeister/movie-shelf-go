class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      log_in(user)
      current_user
      redirect_to root_url
    else
      flash[:danger] = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:info] = "Logged out!"
    redirect_to root_url
  end
end
