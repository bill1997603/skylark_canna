class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env['omniauth.auth'])
    
    if user
      login_as user
      remember_me
      redirect_back_or_default users_papers_url
    else
      redirect_to login_url
    end
  end

  private

  def login_url(return_to)
    store_location return_to
    '/auth/skylark'
  end
end
