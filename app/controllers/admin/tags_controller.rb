class Admin::TagsController < Admin::ApplicationController
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html do
        render layout: false
      end

      format.json { render json: @tags.to_json(only: [:id, :description]) }
    end
  end
end
