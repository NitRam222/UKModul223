require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @max = users(:user_max)
    @anna = users(:user_anna)
    @admin = users(:admin)
    @available_device = devices(:available_laptop)
    @borrowed_device = devices(:borrowed_laptop)
    @active_loan = loans(:active_loan) # belongs to max
  end

  test "redirects to login when unauthenticated" do
    get my_loans_path
    assert_redirected_to login_path
  end

  test "displays user active and past loans" do
    sign_in_as(@max)
    get my_loans_path
    assert_response :success
    assert_select "h1", "Meine Ausleihen"
    assert_match @active_loan.device.name, response.body
  end

  test "user successfully borrows an available device" do
    sign_in_as(@anna)
    assert_difference "Loan.count", 1 do
      post device_loans_path(@available_device), params: { notes: "Test Ausleihe" }
    end

    assert_redirected_to my_loans_path
    follow_redirect!
    assert_match "erfolgreich ausgeliehen", response.body
    assert_not @available_device.reload.available?
  end

  test "user cannot borrow an already borrowed device and receives friendly error" do
    sign_in_as(@anna)
    assert_no_difference "Loan.count" do
      post device_loans_path(@borrowed_device)
    end

    assert_redirected_to devices_path
    follow_redirect!
    assert_match "Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen", response.body
  end

  test "user can return their own loan" do
    sign_in_as(@max)
    patch return_device_loan_path(@active_loan)
    assert_redirected_to my_loans_path
    follow_redirect!
    assert_match "erfolgreich zurückgegeben", response.body
    assert @active_loan.reload.returned?
    assert @active_loan.device.reload.available?
  end

  test "user cannot return another user's loan" do
    sign_in_as(@anna)
    patch return_device_loan_path(@active_loan) # belongs to max
    assert_redirected_to my_loans_path
    follow_redirect!
    assert_match "Ausleihe nicht gefunden oder Zugriff verweigert", response.body
    assert_not @active_loan.reload.returned?
  end

  test "admin can return any user's loan" do
    sign_in_as(@admin)
    patch return_device_loan_path(@active_loan)
    assert_redirected_to my_loans_path
    assert @active_loan.reload.returned?
  end
end
