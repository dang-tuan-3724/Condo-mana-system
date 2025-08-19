require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @super_admin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @house_owner = users(:house_owner)
    @house_member = users(:house_member)
  @notification = notifications(:test1)
  end

  test "index requires authentication" do
    get notifications_url
    assert_redirected_to new_user_session_path
  end

  test "index allows signed in user" do
    sign_in @house_member
    get notifications_url
    assert_response :success
  end

  test "show marks notification as read when owner views" do
    sign_in @house_member
    # ensure notification belongs to this user for this test
    @notification.update!(user: @house_member, status: "unread")

    get notification_url(@notification)
    assert_response :success
    @notification.reload
    assert_equal "read", @notification.status
  end

  test "show authorised for superadmin even if not owner" do
    sign_in @super_admin
    get notification_url(@notification)
    assert_response :success
  end

  test "create success sets notice and redirects" do
    sign_in @super_admin
    assert_difference "Notification.count", 1 do
      post notifications_url, params: { notification: { message: "Hello" } }
    end
  created = Notification.find_by(message: "Hello", user: @super_admin)
  assert created.present?, "expected a notification to be created for super_admin"
  assert_redirected_to notification_url(created)
    assert_equal "Notification was successfully created.", flash[:notice]
  end

  test "create failure renders new" do
    sign_in @super_admin
    post notifications_url, params: { notification: { message: "" } }
    assert_response :unprocessable_entity
    assert_template :new
  end

  test "test action requires authentication" do
    get test_notifications_url
    assert_redirected_to new_user_session_path
  end

  test "test_user_notification broadcasts and redirects back" do
    sign_in @house_member
    # Capture broadcast calls by stubbing ActionCable.server
    orig_server = ActionCable.server
    fake_server = Object.new
    def fake_server.broadcast(channel, payload)
      # no-op; we just ensure it doesn't raise
    end
    ActionCable.singleton_class.send(:define_method, :server) { fake_server }

    begin
      post test_user_notification_notifications_url, headers: { "HTTP_REFERER" => root_path }
      assert_redirected_to root_path
      assert_equal "User notification sent!", flash[:notice]
    ensure
      ActionCable.singleton_class.send(:define_method, :server) { orig_server }
    end
  end

  test "test_admin_notification requires admin role" do
    sign_in @house_member
    post test_admin_notification_notifications_url
    assert_redirected_to root_path
    # Now as admin
    sign_in @operation_admin
    orig_server = ActionCable.server
    fake_server = Object.new
    def fake_server.broadcast(channel, payload)
    end
    ActionCable.singleton_class.send(:define_method, :server) { fake_server }
    begin
      post test_admin_notification_notifications_url, headers: { "HTTP_REFERER" => root_path }
      assert_redirected_to root_path
      assert_equal "Admin notification sent!", flash[:notice]
    ensure
      ActionCable.singleton_class.send(:define_method, :server) { orig_server }
    end
  end
end
