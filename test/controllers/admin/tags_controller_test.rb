require 'test_helper'

class Admin::TagsControllerTest < ActionController::TestCase
  def setup
    login_as User.create(uid: "test", name: "test", admin: true)
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
  end
end
