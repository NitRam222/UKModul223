require "test_helper"

class AdminControllersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user = users(:user_max)
    @device = devices(:available_laptop)
  end

  # =========================================================================
  # Berechtigungspruefung:
  # Normale Benutzer dürfen keine Administratorfunktionen verwenden.
  # =========================================================================

  test "normal user is denied access to admin devices" do
    sign_in_as(@user)
    get admin_devices_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Zugriff verweigert", response.body
  end

  test "normal user is denied access to admin loans" do
    sign_in_as(@user)
    get admin_loans_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Zugriff verweigert", response.body
  end

  test "normal user is denied access to admin users management" do
    sign_in_as(@user)
    get admin_users_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Zugriff verweigert", response.body
  end

  test "normal user is denied access to admin activity logs" do
    sign_in_as(@user)
    get admin_activity_logs_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Zugriff verweigert", response.body
  end

  # =========================================================================
  # Administrator-Funktionen
  # =========================================================================

  test "admin can access admin dashboard and devices" do
    sign_in_as(@admin)
    get admin_devices_path
    assert_response :success
    assert_select "h1", "Geräteverwaltung"
  end

  test "admin can create a new device" do
    sign_in_as(@admin)
    assert_difference "Device.count", 1 do
      post admin_devices_path, params: {
        device: {
          name: "Neuer Beamer",
          category: "Zubehör",
          inventory_code: "BEAM-001",
          description: "4K Laser Projektor",
          active: true
        }
      }
    end

    assert_redirected_to admin_devices_path
    follow_redirect!
    assert_match "erfolgreich erstellt", response.body
  end

  test "admin can edit an existing device" do
    sign_in_as(@admin)
    patch admin_device_path(@device), params: {
      device: {
        name: "Aktualisierter Laptop",
        category: "Laptop",
        inventory_code: @device.inventory_code,
        description: "Neue Beschreibung",
        active: true
      }
    }

    assert_redirected_to admin_devices_path
    assert_equal "Aktualisierter Laptop", @device.reload.name
  end

  test "admin can toggle device active status" do
    sign_in_as(@admin)
    assert @device.active?

    patch toggle_status_admin_device_path(@device)
    assert_redirected_to admin_devices_path
    assert_not @device.reload.active?

    patch toggle_status_admin_device_path(@device)
    assert @device.reload.active?
  end

  test "admin cannot deactivate a device that is currently borrowed" do
    sign_in_as(@admin)
    borrowed_dev = devices(:borrowed_laptop)

    patch toggle_status_admin_device_path(borrowed_dev)
    assert_redirected_to admin_devices_path
    follow_redirect!
    assert_match "aktuell noch ausgeliehen und kann erst nach erfolgter Rückgabe deaktiviert werden", response.body
    assert borrowed_dev.reload.active?
  end

  test "admin can view all loans across users" do
    sign_in_as(@admin)
    get admin_loans_path
    assert_response :success
    assert_select "h1", "Admin: Alle Ausleihen"
    assert_match loans(:active_loan).user.name, response.body
  end

  test "admin can manage users and toggle user roles" do
    sign_in_as(@admin)
    get admin_users_path
    assert_response :success

    target_user = users(:user_anna)
    assert_equal "user", target_user.role

    patch toggle_role_admin_user_path(target_user)
    assert_redirected_to admin_users_path
    assert_equal "admin", target_user.reload.role
  end

  test "admin cannot revoke their own admin role" do
    sign_in_as(@admin)
    patch toggle_role_admin_user_path(@admin)
    assert_redirected_to admin_users_path
    follow_redirect!
    assert_match "eigene Administratorrolle nicht entziehen", response.body
    assert @admin.reload.admin?
  end

  test "admin cannot deactivate themselves" do
    sign_in_as(@admin)
    patch toggle_active_admin_user_path(@admin)
    assert_redirected_to admin_users_path
    follow_redirect!
    assert_match "eigenes Benutzerkonto nicht deaktivieren", response.body
    assert @admin.reload.active?
  end

  test "admin can view activity audit logs" do
    sign_in_as(@admin)
    get admin_activity_logs_path
    assert_response :success
    assert_select "h1", "Aktivitätsprotokoll (Audit Trail)"
  end
end
