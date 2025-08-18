require "test_helper"

class BookingExpirationJobTest < ActiveJob::TestCase
    test "should approve expired bookings" do
      booking = create(:booking, status: "pending", created_at: 2.days.ago, purpose: "Test", booking_time_slots: { "monday" => [ "07:00-08:00" ] })
      BookingExpirationJob.perform_now
      booking.reload
      assert_equal "approved", booking.status
    end

    test "should do nothing if no expired bookings" do
      booking = create(:booking, status: "pending", created_at: Time.current, purpose: "Test", booking_time_slots: { "monday" => [ "07:00-08:00" ] })
      BookingExpirationJob.perform_now
      booking.reload
      assert_equal "pending", booking.status
    end
end
