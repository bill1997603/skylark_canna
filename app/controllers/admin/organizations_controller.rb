class Admin::OrganizationsController < Admin::ApplicationController
  def index
    @organizations = Organization.find(SkylarkAdapter.fetch_organizations(:root))
    SyncOrganizationsJob.perform_later

    respond_to do |format|
      format.json do
        render json: @organizations.to_json(only: [:id, :name, :children_count])
      end
    end
  end

  def children
    parent = Organization.find(params[:id])
    @organizations = Organization.find(SkylarkAdapter.fetch_organizations(parent.uid))
    SyncOrganizationsJob.perform_later parent.uid

    respond_to do |format|
      format.json do
        render json: @organizations.to_json(only: [:id, :name, :children_count])
      end
    end
  end
end
