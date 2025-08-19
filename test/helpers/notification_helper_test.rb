require "test_helper"

class NotificationHelperTest < ActiveSupport::TestCase
  # We'll extend a plain object with the helper to call its methods directly

  test "broadcast_condo_notification calls broadcast_user_notification for each user with default type" do
    helper = Object.new
    helper.extend(NotificationHelper)

    condo = condos(:vinhomes)
    message = "Hello condo"

    recorded = []
    helper.define_singleton_method(:broadcast_user_notification) do |user_id, msg, opts = {}|
      type = opts.is_a?(Hash) ? opts[:type] : opts
      recorded << [ user_id, msg, type ]
    end
    helper.broadcast_condo_notification(condo.id, message)

    expected_user_ids = User.where(condo_id: condo.id).pluck(:id).map(&:to_s).sort
    actual_user_ids = recorded.map { |r| r[0].to_s }.sort

    assert_equal expected_user_ids, actual_user_ids
    assert recorded.all? { |(_, msg, type)| msg == message && type == "info" }
  end

  test "broadcast_condo_notification forwards custom type and does nothing for empty condo" do
    helper = Object.new
    helper.extend(NotificationHelper)

    condo_with_users = condos(:vinhomes)
    message = "Alert for condo"

    recorded = []
    helper.define_singleton_method(:broadcast_user_notification) do |user_id, msg, opts = {}|
      type = opts.is_a?(Hash) ? opts[:type] : opts
      recorded << [ user_id, msg, type ]
    end
    helper.broadcast_condo_notification(condo_with_users.id, message, type: "alert")

    assert recorded.any?
    assert recorded.all? { |(_, msg, type)| msg == message && type == "alert" }

    # choose a condo that has no users in fixtures (landmark81 has none)
    recorded_empty = []
    helper.define_singleton_method(:broadcast_user_notification) do |user_id, msg, opts = {}|
      type = opts.is_a?(Hash) ? opts[:type] : opts
      recorded_empty << [ user_id, msg, type ]
    end
    helper.broadcast_condo_notification(condos(:landmark81).id, "No one here")
    assert_empty recorded_empty
  end
end
