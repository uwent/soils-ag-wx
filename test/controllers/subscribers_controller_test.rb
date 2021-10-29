require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  setup do
    @subscriber = subscribers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_nil assigns(:subscribers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subscriber" do
    assert_difference('Subscriber.count') do
      post :create, params: {
        subscriber: {
          confirmed_at: '2020-10-10',
          email: 'new_user@example.com',
          name: 'New User'
          }
        }
    end

    assert_redirected_to confirm_notice_subscriber_path(assigns(:subscriber))
  end

  test "should update subscriber" do
    admin = subscribers(:two)
    admin.update!(admin: true)
    session[:subscriber] = admin.id
    patch :update, params: {
      id: @subscriber,
      format: :json,
      subscriber: {
        confirmed_at: @subscriber.confirmed_at,
        email: @subscriber.email,
        name: @subscriber.name
      }
    }
    assert_response :success
  end

  test "should destroy subscriber" do
    admin = subscribers(:two)
    admin.update!(admin: true)
    session[:subscriber] = admin.id
    assert_difference('Subscriber.count', -1) do
      delete :destroy, params: { id: @subscriber }
    end

    assert_redirected_to admin_subscribers_path
  end
end
