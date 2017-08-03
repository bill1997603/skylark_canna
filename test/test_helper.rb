require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

class ActionController::TestCase
  %w(login_as logout current_user login?).each do |method|
    define_method method do |*args|
      @controller.send method, *args
    end
  end
end
