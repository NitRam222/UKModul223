require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_max)
    @inactive_user = users(:user_inactive)
  end

  test "should get login page" do
    get login_path
    assert_response :success
    assert_select "h1", "Anmelden"
  end

  test "should login with valid credentials" do
    post login_path, params: { email: @user.email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Willkommen zurück, #{@user.name}!", response.body
    assert_equal @user.id, session[:user_id]
  end

  test "should reject login with wrong password" do
    post login_path, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_match "Ungültige E-Mail-Adresse oder falsches Passwort", response.body
    assert_nil session[:user_id]
  end

  test "should reject login for inactive user" do
    post login_path, params: { email: @inactive_user.email, password: "password123" }
    assert_response :forbidden
    assert_match "Ihr Benutzerkonto ist deaktiviert", response.body
    assert_nil session[:user_id]
  end

  test "should logout successfully" do
    sign_in_as(@user)
    delete logout_path
    assert_redirected_to login_path
    follow_redirect!
    assert_match "erfolgreich abgemeldet", response.body
    assert_nil session[:user_id]
  end
end
