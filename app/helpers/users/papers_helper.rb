module Users::PapersHelper
  def finished?(paper)
    !!@current_user.enrolls.find_by(paper: paper).hand_in_time
  end

  def failed?(enroll)
    enroll.score < enroll.paper.assigns.sum(:problem_score) * 0.6
  end

  def done_wrong?(chosen_list, problem_id)
    !chosen_list.detect do |chosen|
      problem_id_t, chosen_option_ids = chosen.split('-')

      (problem_id_t.to_i == problem_id) && (Problem.find(problem_id).right?(chosen_option_ids))
    end
  end

  def chosen?(chosen_list, problem_id, option_id)
    !!chosen_list.detect do |chosen|
      problem_id_t, chosen_option_ids = chosen.split('-')

      (problem_id_t.to_i == problem_id) && (!!chosen_option_ids&.split(';')&.detect { |chosen_option_id| chosen_option_id.to_i == option_id })
    end
  end
end
