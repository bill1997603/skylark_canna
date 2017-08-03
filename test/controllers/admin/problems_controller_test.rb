require 'test_helper'

class Admin::ProblemsControllerTest < ActionController::TestCase
  def setup
    login_as User.create(uid: "test", name: "test", admin: true)
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should get show page" do
    get :show, params: {id: create(:problem)}
    assert_response :success, @response.body
  end

  test "should create Problem" do
    assert_difference ["Problem.count"] do
      options_attributes = Array.new(3, attributes_for(:option))
      options_attributes << attributes_for(:option, :right)
      post :create, xhr: true, params: { problem: attributes_for(:problem).merge(options_attributes: options_attributes) }
    end
  end

  test "should trash problem" do
    problem = create(:problem)

    assert_difference "Problem.untrashed.count", -1 do
      delete :destroy, params: {id: problem}
    end
  end

  test "should get template" do
    get :template
    assert_response :success
    assert_equal "text/csv", response.content_type
  end
end
