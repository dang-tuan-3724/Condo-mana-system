require "test_helper"

class AdminNotificationChannelTest < ActionCable::Channel::TestCase
  tests ::AdminNotificationChannel
  test "admin can subscribe to admin_notifications" do
    admin = users(:super_admin)
    stub_connection current_user: admin
    subscribe
    assert subscription.confirmed?
    assert_has_stream "admin_notifications"
  end

  test "non-admin is rejected from admin channel" do
    user = users(:house_member)
    stub_connection current_user: user
    subscribe
    refute subscription.confirmed?
  end
end
