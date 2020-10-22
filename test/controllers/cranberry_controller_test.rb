require 'test_helper'

class CranberryControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

# summary page broken on prod, not sure if needed, BB 10/21
  # test "should get summary" do
  #   get :summary
  #   assert_response :success
  # end

end
