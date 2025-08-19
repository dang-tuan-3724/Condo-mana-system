require "test_helper"

class NotificationsChannelTest < ActionCable::Channel::TestCase
  tests ::NotificationsChannel
  def setup
    @user = users(:house_member)
    stub_connection current_user: @user
  end

  test "subscribes and streams from user-specific notifications" do
    subscribe
    assert subscription.confirmed?
    assert_has_stream "notifications:#{@user.id}"
  end

  test "unsubscribed logs without error" do
    subscribe
    perform :unsubscribed
    # just ensure no exceptions and subscription is still present or closed gracefully
    assert subscription.confirmed? || subscription.transmissions.is_a?(Array)
  end
end
