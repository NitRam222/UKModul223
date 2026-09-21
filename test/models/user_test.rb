require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:user_max)
    @admin = users(:admin)
  end

  test "valid user with attributes" do
    user = User.new(
      name: "Test User",
      email: "test.unique@beispiel.ch",
      password: "password123",
      role: "user"
    )
    assert user.valid?
  end

  test "requires name and email" do
    user = User.new
    assert_not user.valid?
    assert user.errors[:name].any?
    assert user.errors[:email].any?
  end

  test "enforces unique email address case-insensitively" do
    duplicate = User.new(
      name: "Duplicate",
      email: @user.email.upcase,
      password: "password123",
      role: "user"
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "validates email format" do
    user = User.new(name: "Invalid Email", email: "not-an-email", password: "password123", role: "user")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "validates role inclusion" do
    user = User.new(name: "Bad Role", email: "badrole@beispiel.ch", password: "password123", role: "superadmin")
    assert_not user.valid?
    assert user.errors[:role].any?
  end

  test "role helpers work as expected" do
    assert @admin.admin?
    assert_not @admin.user?
    assert_equal "Administrator", @admin.role_name

    assert @user.user?
    assert_not @user.admin?
    assert_equal "Benutzer", @user.role_name
  end

  test "active loans association returns currently unreturned loans" do
    assert_equal 1, @user.active_loans.count
    assert_equal devices(:borrowed_laptop), @user.active_loans.first.device
  end
end
