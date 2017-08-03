require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @tag = build(:tag)
  end

  test "should be valid" do
    assert @tag.valid?
  end

  test "description should be present" do
    @tag.description = ""
    assert_not @tag.valid?
  end

  test "description should be unique" do
    @tag.save
    new_tag = build(:tag)
    assert_not new_tag.valid?
  end

  test "description should be less than 10 words" do
    @tag.description = "12345678910"
    assert_not @tag.valid?
  end

  test "should create tags from tags_list" do
    problem = build(:problem)
    problem.options.build(description: "Example description")
    problem.options.build(description: "Example description", right: true)
    problem.tags_list = "A;B"
    assert_difference 'Tag.count', 2 do
      problem.save
    end
  end

  test "should add existing tag" do
    problem = build(:problem)
    problem.options.build(description: "Example description")
    problem.options.build(description: "Example description", right: true)
    problem.tags_list = "A;B"
    problem.save
    assert_difference 'Tag.count' do
      problem.tags_list = "B;C"
      problem.save
    end
  end
end
