require "test_helper"

ActiveJob::Base.queue_adapter = :test

class BookingConflictResolutionJobTest < ActiveJob::TestCase
  test "job is enqueued" do
    assert_enqueued_with(job: BookingConflictResolutionJob) do
      BookingConflictResolutionJob.perform_later
    end
  end
  test "job performs as expected" do
    booking = bookings(:swimming)
    assert_no_difference "Booking.count" do
      BookingConflictResolutionJob.perform_later(booking)
    end
  end

  test "job return nil if status is not pending" do
    booking = bookings(:swimming)
    booking.update(status: "approved")
    assert_nil BookingConflictResolutionJob.new.perform(booking.id)
  end

  test "job logs conflict if overlapping booking" do
    booking = bookings(:swimming)
    # Tạo một booking khác trùng slot với booking này
    conflict_booking = Booking.new(
      user: booking.user,
      facility_id: booking.facility_id,
      status: "pending",
      booking_time_slots: booking.booking_time_slots,
      purpose: "Test"
    )
    conflict_booking.save(validate: false) # tạm thời tắt validate ở model 0 vì tuấn đã hiện thực cả 2 chổ check overlap, model, sau đó là job

    # phải dùng cú pháp này vì minitest đang dùng không hỗ trợ assert_logged
    log_output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = Logger.new(log_output)
    BookingConflictResolutionJob.new.perform(conflict_booking.id)
    Rails.logger = original_logger
    assert_match(/conflicts: Time slot/, log_output.string)
  end
end
