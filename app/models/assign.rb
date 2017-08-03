class Assign < ApplicationRecord
  belongs_to :problem
  belongs_to :paper

  def self.score_for(assigns_attributes)
    total_score = 0
    chosen_list = []

    assigns_attributes.each_pair do |key, value|
      assign = Assign.find(key)
      problem = assign.problem

      chosen_list << "#{problem.id}-#{value[:chosen]}"

      if problem.right?(value[:chosen])
        total_score = total_score + assign.problem_score
      end
    end

    [total_score, chosen_list]
  end
end
