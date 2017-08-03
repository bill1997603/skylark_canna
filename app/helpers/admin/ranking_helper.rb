module Admin::RankingHelper
  def score(user, period)
    case period
    when :week
      user.enrolls.current_week.sum(:score)
    when :month
      user.enrolls.current_month.sum(:score)
    when :quarter
      user.enrolls.current_quarter.sum(:score)
    end
  end

  def num_of_references(user, period)
    enrolls = user.enrolls.finished
    case period
    when :week
      enrolls.current_week.count
    when :month
      enrolls.current_month.count
    when :quarter
      enrolls.current_quarter.count
    end
  end

  def score_of_company(org, period)
    enrolls = Enroll.where(user_id: org.user_ids)

    case period
    when :month
      enrolls.current_month.sum(:score)
    when :quarter
      enrolls.current_quarter.sum(:score)
    end
  end

  def num_of_references_of_company(org, period)
    enrolls = Enroll.finished.where(user_id: org.user_ids)

    case period
    when :month
      enrolls.current_month.count
    when :quarter
      enrolls.current_quarter.count
    end
  end

  def link_to_export_individual(period, name, html_options = nil)
    export_url = "#{admin_ranking_individual_export_url}?period=#{period}"
    link_to name, export_url, html_options
  end

  def link_to_export_company(period, name, html_options = nil)
    export_url = "#{admin_ranking_company_export_url}?period=#{period}"
    link_to name, export_url, html_options
  end
end
