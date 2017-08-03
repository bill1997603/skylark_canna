class Admin::ApplicationController < ApplicationController
  layout 'admin'

  class AccessDenied < Exception; end

  before_action :login_required, :admin_required

  def filter_problems
    @problems = Problem.untrashed.preload(:options, :tags).order(id: :desc).page(params[:page])
    if params[:tag]
      @problems = @problems.joins(:tags).where({ tags: { description: params[:tag] } })
      @remote = true
    elsif params[:form]
      if params[:form] == '1'
        @problems = @problems.single
      else
        @problems = @problems.multi
      end
      @remote = true
    end

    [@problems, @remote]
  end

  def set_nav(key, value)
    @nav_options = { key => value }
  end

  def admin_required
    raise AccessDenied unless current_user.admin?
  end

  def login_url(return_to)
    admin_login_url(return_to)
  end
end
