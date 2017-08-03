class Admin::SessionsController < Admin::ApplicationController
  layout :false
  skip_before_action :login_required, :admin_required

  def new
    store_location params[:return_to]
  end

  def create
    login = login_params[:login]
    password = login_params[:password]

    @user = User.find_and_auth_admin(login, password)

    if @user
      login_as @user
      remember_me
      redirect_back_or_default admin_root_url
    else
      render :new
    end
  end

  def destroy
    logout
    redirect_to admin_login_url
  end

  def login_params
    params.require(:user).permit(:login, :password)
  end
end
