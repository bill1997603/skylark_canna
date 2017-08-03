require 'test_helper'

class Admin::PapersControllerTest < ActionController::TestCase
  def setup
    login_as User.create(uid: "test", name: "test", admin: true)
  end

  test "should create Paper" do
    assert_difference ["Paper.count"] do
      id_1 = create(:problem).id
      id_2 = create(:problem).id
      problems_list = "#{id_1}-5;#{id_2}-6"
      post :create, params: { paper: attributes_for(:paper, problems_list: problems_list) }
    end
  end
end
