class Users::ApplicationController < ApplicationController
  layout 'users'

  before_action :login_required, :select_company_required

  def select_company_required
    unless @current_user.company
      redirect_to new_users_organization_url(return_to: (request.fullpath if request.get?))
    end
  end

  def login_url(params)
    store_location params[:return_to]
    '/auth/skylark'
  end
end
