require 'test_helper'

class ObservationSessionsControllerTest < ActionController::TestCase
  setup do
    @observation_session = observation_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:observation_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create observation_session" do
    assert_difference('ObservationSession.count') do
      post :create, observation_session: { end_jd: @observation_session.end_jd, start_jd: @observation_session.start_jd }
    end

    assert_redirected_to observation_session_path(assigns(:observation_session))
  end

  test "should show observation_session" do
    get :show, id: @observation_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @observation_session
    assert_response :success
  end

  test "should update observation_session" do
    patch :update, id: @observation_session, observation_session: { end_jd: @observation_session.end_jd, start_jd: @observation_session.start_jd }
    assert_redirected_to observation_session_path(assigns(:observation_session))
  end

  test "should destroy observation_session" do
    assert_difference('ObservationSession.count', -1) do
      delete :destroy, id: @observation_session
    end

    assert_redirected_to observation_sessions_path
  end
end
