module Admin::PapersHelper
  def display_time(time)
    time.localtime.strftime("%Y年%m月%d日 %H:%M") unless time.nil?
  end

  def num_of_failed(paper)
    total = paper.assigns.sum(:problem_score)
    paper.enrolls.where('score < ?', total * 0.6).count
  end

  def other_params_field
    if params[:status]
      hidden_field_tag :status, params[:status]
    elsif params[:rank]
      hidden_field_tag :rank, params[:rank]
    elsif params[:failed]
      hidden_field_tag :failed, params[:failed]
    end
  end

  def rank_of(i)
    if params[:page]
      i + 1 + 20 * (params[:page].to_i - 1)
    else
      i + 1
    end
  end
end
