require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_max)
    @available = devices(:available_laptop)
  end

  test "redirects to login when unauthenticated" do
    get devices_path
    assert_redirected_to login_path
  end

  test "shows devices list when authenticated" do
    sign_in_as(@user)
    get devices_path
    assert_response :success
    assert_select "h1", "Geräteübersicht"
    assert_match @available.name, response.body
  end

  test "filters devices by category" do
    sign_in_as(@user)
    get devices_path, params: { category: "Kamera" }
    assert_response :success
    assert_match devices(:camera).name, response.body
    assert_no_match @available.name, response.body
  end

  test "searches devices by keyword" do
    sign_in_as(@user)
    get devices_path, params: { query: @available.inventory_code }
    assert_response :success
    assert_match @available.name, response.body
  end

  test "shows device details" do
    sign_in_as(@user)
    get device_path(@available)
    assert_response :success
    assert_match @available.name, response.body
    assert_match @available.inventory_code, response.body
  end
end
