require "test_helper"

class BookingWorkflowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:user_1)
    @super_admin = users(:super_admin)
    @operation_admin = users(:operation_admin)
  end

  test "create booking and super admin will approve it" do
    sign_in @user
    booking = Booking.new(
      user_id: users(:user_1).id,
      facility: facilities(:vinhomes_pool),
      booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
      purpose: "Test booking",
      status: "pending"
    )
    assert_difference "Booking.count", 1 do
      booking.save
    end
    sign_in @super_admin
    patch booking_url(booking), params: { booking: { status: "approved" } }
    assert_equal "approved", booking.reload.status
    assert_redirected_to bookings_url
  end
end
