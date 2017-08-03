require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(uid: 'foo', name: 'bar')
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "uid should be present" do
    @user.uid = ''
    assert_not @user.valid?
  end

  test "uid should be unique" do
    @user.save
    user = User.new(uid: 'foo', name: 'bar')
    assert_not user.valid?
  end

  test "name should be present" do
    @user.name = ''
    assert_not @user.valid?
  end
end
