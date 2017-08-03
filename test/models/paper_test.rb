require 'test_helper'

class PaperTest < ActiveSupport::TestCase
  def setup
    @problem = create(:problem)
    @paper = build(:paper, deadline: Time.now + 1.day, problems_list: "#{@problem.id}-5")
  end

  test 'should be valid' do
    assert @paper.valid?
  end

  test "deadline should be after now" do
    @paper.deadline = Time.now - 1.day
    assert_not @paper.save
  end

  test "should add problems from problems_list" do
    id_1 = create(:problem).id
    id_2 = create(:problem).id
    problems_list = "#{id_1}-3;#{id_2}-5"
    paper = build(:paper, deadline: Time.now + 1.day, problems_list: problems_list)
    paper.save
    assert paper.problems.reload.ids.include?(id_1) && paper.problems.ids.include?(id_2)
    assert_equal paper.assigns.where(problem_id: id_1).first.problem_score, 3
    assert_equal paper.assigns.where(problem_id: id_2).first.problem_score, 5
  end
end
