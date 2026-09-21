require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_max)
  end

  test "requires login to view profile" do
    get profile_path
    assert_redirected_to login_path
  end

  test "user can view their own profile" do
    sign_in_as(@user)
    get profile_path
    assert_response :success
    assert_match @user.name, response.body
    assert_match @user.email, response.body
  end

  test "user can update their name and email" do
    sign_in_as(@user)
    patch profile_path, params: {
      user: {
        name: "Max Neuer Name",
        email: "max.neu@beispiel.ch"
      }
    }
    assert_redirected_to profile_path
    follow_redirect!
    assert_match "Profil erfolgreich aktualisiert", response.body
    assert_equal "Max Neuer Name", @user.reload.name
    assert_equal "max.neu@beispiel.ch", @user.email
  end

  test "user can change password with correct current password" do
    sign_in_as(@user)
    patch profile_path, params: {
      user: {
        password: "newsecretpassword",
        password_confirmation: "newsecretpassword",
        current_password: "password123"
      }
    }
    assert_redirected_to profile_path
    assert @user.reload.authenticate("newsecretpassword")
  end

  test "password change fails if current password is wrong" do
    sign_in_as(@user)
    patch profile_path, params: {
      user: {
        password: "newsecretpassword",
        password_confirmation: "newsecretpassword",
        current_password: "wrongpassword"
      }
    }
    assert_response :unprocessable_entity
    assert_match "ist nicht korrekt", response.body
    assert @user.reload.authenticate("password123")
  end
end
