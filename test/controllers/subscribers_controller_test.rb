require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  setup do
    @subscriber = subscribers(:one)
  end
  # TODO
  test "should get index" do
    get :index
    assert_response :success
    assert_nil assigns(:subscribers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # test "should create subscriber" do
  #   assert_difference('Subscriber.count') do
  #     post :create, subscriber: { confirmation_token: @subscriber.confirmation_token, email: @subscriber.email, name: @subscriber.name }
  #   end
  #
  #   assert_redirected_to subscriber_path(assigns(:subscriber))
  # end

  # TODO potentially remove, view exists, but route does not, not sure if functional, or needed, note from 4 years ago - "emails still needed"
  # test "should show subscriber" do
  #   get :show, id: @subscriber
  #   assert_response :success
  # end

  # test "should update subscriber" do
  #   patch :update, id: @subscriber, subscriber: { confirmation_token: @subscriber.confirmation_token, email: @subscriber.email, name: @subscriber.name}
  #   assert_redirected_to subscriber_path(assigns(:subscriber))
  # end

  # test "should destroy subscriber" do
  #   assert_difference('Subscriber.count', -1) do
  #     delete :destroy, id: @subscriber
  #   end
  #
  #   assert_redirected_to subscribers_path
  # end
end
