require 'test_helper'

class OptionTest < ActiveSupport::TestCase
  def setup
    @option = Option.new(description: 'Example description')
    @problem = Problem.new(description: 'Example description')
    @option.problem = @problem
  end

  test "should be valid" do
    assert @option.valid?
  end

  test "description should be present" do
    @option.description = ''
    assert_not @option.valid?
  end
end
