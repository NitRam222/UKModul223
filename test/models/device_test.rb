require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  setup do
    @available = devices(:available_laptop)
    @borrowed = devices(:borrowed_laptop)
    @inactive = devices(:inactive_device)
  end

  test "valid device" do
    device = Device.new(
      name: "iPad Air",
      category: "Tablet",
      inventory_code: "TAB-099",
      description: "Apple iPad Air M2",
      active: true
    )
    assert device.valid?
  end

  test "requires name, category and inventory_code" do
    device = Device.new
    assert_not device.valid?
    assert device.errors[:name].any?
    assert device.errors[:category].any?
    assert device.errors[:inventory_code].any?
  end

  test "requires unique inventory code" do
    dup = Device.new(
      name: "Duplicate",
      category: "Laptop",
      inventory_code: @available.inventory_code
    )
    assert_not dup.valid?
    assert dup.errors[:inventory_code].any?
  end

  test "validates category against permitted list" do
    device = Device.new(
      name: "Smart Watch",
      category: "Wearable",
      inventory_code: "WAT-001"
    )
    assert_not device.valid?
    assert device.errors[:category].any?
  end

  test "availability status" do
    assert @available.available?
    assert_equal "Verfügbar", @available.status_label

    assert_not @borrowed.available?
    assert_equal "Ausgeliehen", @borrowed.status_label
    assert_equal users(:user_max), @borrowed.current_borrower

    assert_not @inactive.available?
    assert_equal "Inaktiv", @inactive.status_label
  end

  test "scopes filter devices correctly" do
    assert_includes Device.active, @available
    assert_not_includes Device.active, @inactive

    assert_includes Device.by_category("Laptop"), @available
    assert_not_includes Device.by_category("Laptop"), devices(:camera)

    results = Device.search("Dell")
    assert_includes results, @available
  end
end
