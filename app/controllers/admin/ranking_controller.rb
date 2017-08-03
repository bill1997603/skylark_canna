require 'csv'

class Admin::RankingController < Admin::ApplicationController
  before_action { set_nav(:ranking, true) }

  def dash
  end

  def individual
    @users = User.includes(:organizations).order_by_score_for(params[:period].to_sym).page(params[:page])
  end

  def company
    @organizations = Organization.order_by_score_for(params[:period].to_sym).page(params[:page])
  end

  def export_individual
    send_data(Exporter::ExcelExporter.export_individual_ranking(params[:period].to_sym), type: 'application/xlsx', filename: "#{Time.now.to_i}.xlsx")
  end

  def export_company
    send_data(Exporter::ExcelExporter.export_company_ranking(params[:period].to_sym), type: 'application/xlsx', filename: "#{Time.now.to_i}.xlsx")
  end

  def push_individual
    PushRankJob.perform_later(nil, 1, params[:period])
  end

  def push_company
    PushRankJob.perform_later(nil, 2, params[:period])
  end
end
