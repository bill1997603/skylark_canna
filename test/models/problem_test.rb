require 'test_helper'

class ProblemTest < ActiveSupport::TestCase
  def setup
    @problem = Problem.new(description: 'Example description')
    @problem.options.build(description: 'Example description', right: true)
    @problem.options.build(description: 'Example description')
  end

  test 'should be valid' do
    assert @problem.valid?
  end

  test 'description should be present' do
    @problem.description = ''
    assert_not @problem.valid?
  end

  test 'form should be within 1, 2, 3' do
    @problem.form = 4
    assert_not @problem.valid?
  end

  test "should have at least 2 options" do
    @problem.options = []
    assert_not @problem.valid?
    @problem.options.build(description: 'Example description')
    assert_not @problem.valid?
  end

  test "should have at least 1 right answer" do
    @problem.options.each { |option| option.right = false}
    assert_not @problem.valid?
  end
end
