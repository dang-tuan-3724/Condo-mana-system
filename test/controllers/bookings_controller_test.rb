require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @super_admin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @house_owner = users(:house_owner)
    @house_member = users(:house_member)
    @user = users(:user_1)
    @unit = units(:unit1)
    @booking = bookings(:swimming)
    @condo = condos(:vinhomes)
    @vinhomes_pool = facilities(:vinhomes_pool)
    @user4 = users(:user_4)
  end
  test "should get index for super admin" do
    sign_in @super_admin
    get bookings_url
    assert_response :success
  end
  test "should get index for operation admin" do
    sign_in @operation_admin
    get bookings_url
    assert_response :success
  end
  test "should delete booking" do
    sign_in @super_admin
    assert_difference("Booking.count", -1) do
      delete booking_url(@booking)
    end
    assert_redirected_to bookings_url
  end
  test "should not delete booking for user" do
    sign_in @user
    assert_no_difference("Booking.count") do
      delete booking_url(@booking)
    end
  end
  test "should get new for all users" do
    sign_in @user
    get new_booking_url
    assert_response :success
  end
  test "should update booking state for super admin and operation admin" do
    sign_in @super_admin
    patch booking_url(@booking), params: { booking: { status: "approved" } }
    assert_redirected_to bookings_url
  end
  test "should create for all user" do
    sign_in @user
      # Use a free slot and date to avoid fixture conflicts
      assert_difference("Booking.count") do
        post bookings_url, params: { booking: { facility_id: @vinhomes_pool.id, user_id: @user.id, purpose: "test", booking_time_slots: '{"2025-08-06": ["09:00-10:00"]}' } }
      end
    assert_redirected_to facility_url(@vinhomes_pool)
  end

end
