require 'test_helper'

class Admin::SessionsControllerTest < ActionController::TestCase
  test "should get login page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create session" do
    User.create(uid: "test", name: "test", admin: true)
    assert_not login?
    post :create, params: { user: { login: "test", password: "test" } }
    assert login?
  end

  test "should destroy session" do
    login_as User.create(uid: "test", name: "test", admin: true)
    delete :destroy
    assert_not login?
  end
end
