require "test_helper"

class BookingTest < ActiveSupport::TestCase
  fixtures :bookings, :users, :facilities
  def setup
    @booking1 = bookings(:swimming)
  end

  test "should create booking with valid data" do
    assert_difference "Booking.count" do
      booking = Booking.new(
        user_id: users(:user_1).id,
        facility: facilities(:vinhomes_pool),
        booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
        purpose: "Test booking",
        status: "pending"
      )
      booking.save
    end
  end

  test "should not create booking without user_id" do
    assert_no_difference "Booking.count" do
      booking = Booking.new(
        user_id: nil,
        facility: facilities(:vinhomes_pool),
        booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
        purpose: "Test booking",
        status: "pending"
      )
      booking.save
    end
  end
  test "should not create booking without purpose" do
    assert_no_difference "Booking.count" do
      booking = Booking.new(
        user_id: users(:user_1).id,
        facility: facilities(:vinhomes_pool),
        booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
        purpose: nil,
        status: "pending"
      )
      booking.save
    end
  end
  test "should not create booking with invalid time slot format" do
    assert_no_difference "Booking.count" do
      booking = Booking.new(
        user_id: users(:user_1).id,
        facility: facilities(:vinhomes_pool),
        booking_time_slots: { "2025-08-06" => [ "invalid_time_format" ] },
        purpose: "test",
        status: "pending"
      )
      booking.save
    end
  end

  test "should not create booking with overlapping time slots" do
    assert_difference "Booking.count", 1 do
      booking = Booking.new(
        user_id: users(:user_1).id,
        facility: facilities(:vinhomes_pool),
        booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
        purpose: "Test booking",
        status: "pending"
      )
      booking.save
      overlapping_booking = Booking.new(
        user_id: users(:user_1).id,
        facility: facilities(:vinhomes_pool),
        booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
        purpose: "Test booking",
        status: "pending"
      )
      overlapping_booking.save
    end
  end

  test "should restore time slots to facility v1" do
    booking = bookings(:swimming)
    facility = booking.facility

    removed_slots = booking.booking_time_slots
    removed_slots.each do |date, slots|
      if facility.availability_schedule[date]
        facility.availability_schedule[date] -= slots
      end
    end
    facility.save!
    booking.send(:restore_time_slots_to_facility)
    facility.reload

    removed_slots.each do |date, slots|
      assert((facility.availability_schedule[date] & slots) == slots)
    end
  end

  test "should restore time slots to facility v2" do
    booking = Booking.new(
      user_id: users(:user_1).id,
      facility: facilities(:vinhomes_pool),
      booking_time_slots: { "2025-08-06" => [ "10:00-11:00" ] },
      purpose: "Test booking",
      status: "pending"
    )
    removed_slots = booking.booking_time_slots
    booking.save
    facility = facilities(:vinhomes_pool)
    facility.reload
    updated_slots = facility.availability_schedule

    removed_slots.each do |date, slots|
      if updated_slots[date]
        slots.each do |slot|
          assert_not updated_slots[date].include?(slot), "Slot #{slot} for date #{date} should be removed from facility availability after booking"
        end
      end
    end
  end
end
