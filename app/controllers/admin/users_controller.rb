require 'csv'

class Admin::UsersController < Admin::ApplicationController
  before_action only: [:index] { set_nav(:past_papers, true) }

  def index
    @paper = Paper.find(params[:id])
    @enrolls = @paper.enrolls.includes(user: [:organizations]).order('users.id ASC').page(params[:page])

    if params[:q]
      @enrolls = @enrolls.search(params[:q].to_s)
    end

    if params[:status]
      if params[:status] == '0'
        @enrolls = @enrolls.finished
      else
        @enrolls = @enrolls.unfinished
      end
    elsif params[:rank]
      if params[:rank] == '0'
        @enrolls = @enrolls.finished.reorder(score: :asc)
      else
        @enrolls = @enrolls.finished.reorder(score: :desc)
      end
    elsif params[:failed]
      total = @paper.assigns.sum(:problem_score)
      @enrolls = @enrolls.finished.where('score < ?', total * 0.6)
    end
  end

  def export
    paper = Paper.find(params[:id])
    send_data(Exporter::ExcelExporter.export_paper_ranking(paper), type: 'application/xlsx', filename: "#{Time.now.to_i}.xlsx")
  end
end
