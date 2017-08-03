class Users::RankingController < Users::ApplicationController
  def individual
    @users = User.includes(:organizations).order_by_score_for(params[:period].to_sym)
  end

  def company
    @organizations = Organization.order_by_score_for(params[:period].to_sym)
  end
end
