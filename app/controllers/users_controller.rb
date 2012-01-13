class UsersController < ApplicationController

  before_filter :login_required, except: [:show, :login, :authenticate]

  def show
    @user = User.where(nickname: params[:id]).first
  end

  def edit
    @user = User.where(nickname: params[:id]).first
  end

  def update
    @user = User.where(nickname: params[:id]).first
    if @user.editable_by?(current_user)
      flash[:notice] = "Updated!"
      @user.update_attributes(params[:user])
    else
      flash[:error] = "Heh. No Way, man :)"
    end
    redirect_to @user
  end


  #
  # Session management
  #
  
  def logout
    session.delete(:user_id)
    redirect_to '/'
  end

  def login
    redirect_to '/auth/github'
  end

  def authenticate
    omniauth = request.env["omniauth.auth"]
    user = User.where(github_id: omniauth['uid']).first
    if user
      flash[:notice] = "Signed in successfully."
      session[:user_id] = user.id.to_s
      redirect_to user_path(user)
    else
      user_info = omniauth['user_info']
      user = User.new(nickname: user_info['nickname'], github_name: user_info['nickname'])
      user.github_id = omniauth['uid'] # mass assignemnt not allowed
      if user.save
        session[:user_id] = user.id.to_s
        flash[:notice] = "Signed in successfully."
        redirect_to edit_user_path(user)
      else
        flash[:notice] = "Failed"
        redirect_to root_url
      end
    end
  end
end
