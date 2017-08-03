class Users::OrganizationsController < Users::ApplicationController
  skip_before_action :select_company_required

  def new
    store_location params[:return_to]
    @organizations = @current_user.organizations.leaf.distinct

    redirect_back_or_default(users_papers_url) if @organizations.count == 0
  end

  def create
    @current_user.company = Organization.find params[:company]
    @current_user.save
    redirect_back_or_default users_papers_url
  end
end
