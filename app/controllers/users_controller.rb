class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :edit, :update]

  def new
    if logged_in?
      redirect_to root_path
    else
      @user = User.new
    end
  end

  def create
    @user = User.new(userParams)

    if @user.save
      flash[:success] = "User signed up succesfully!"
      session[:signed_up] = true
      log_in(@user)
      redirect_to root_path
    else
      flash[:danger] = @user.errors.full_messages
      render "new"
    end
  end

  private
    def userParams
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
