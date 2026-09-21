require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get register page" do
    get register_path
    assert_response :success
    assert_select "h1", "Konto erstellen"
  end

  test "should register new user successfully and sign in as regular user" do
    assert_difference "User.count", 1 do
      post register_path, params: {
        user: {
          name: "Neuer Benutzer",
          email: "neu@beispiel.ch",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    new_user = User.find_by(email: "neu@beispiel.ch")
    assert_not_nil new_user
    assert_equal "user", new_user.role
    assert_equal new_user.id, session[:user_id]
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Konto erfolgreich erstellt", response.body
  end

  test "should reject registration with mismatching passwords" do
    assert_no_difference "User.count" do
      post register_path, params: {
        user: {
          name: "Ungültiger Benutzer",
          email: "ungueltig@beispiel.ch",
          password: "password123",
          password_confirmation: "mismatch"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end
end
