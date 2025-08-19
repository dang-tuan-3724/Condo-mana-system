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

  test "create failure with invalid JSON booking_time_slots redirects to facility when facility_id present" do
    sign_in @user
    # Provide invalid JSON string to trigger JSON::ParserError and ensure controller redirects to facility_path
    post bookings_url, params: { booking: { facility_id: @vinhomes_pool.id, purpose: "x", booking_time_slots: '{"2025-08-06": ["09:00-10:00"]' } }

  assert_redirected_to facility_path(@vinhomes_pool)
  # When JSON parse fails we normalize booking_time_slots to nil, model validation adds presence error
  assert_match Regexp.new("Booking time slots can't be blank"), flash[:alert].to_s
  end

  test "create failure with invalid JSON booking_time_slots and no facility redirects to facilities index" do
    sign_in @user
    post bookings_url, params: { booking: { purpose: "x", booking_time_slots: "not a json" } }

  assert_redirected_to facilities_path
  # Expect facility existence + booking_time_slots presence errors when no facility provided
  assert_match Regexp.new("Facility must exist|Booking time slots can't be blank"), flash[:alert].to_s
  end

  test "index search param performs joins and returns matching results" do
    sign_in @super_admin
    get bookings_url, params: { search: "Hồ bơi" }
    assert_response :success
  # Expect the facility name to appear in the rendered response
  assert_match Regexp.new("Hồ bơi"), @response.body
  end

  test "index day param filters bookings and exercises array branch" do
    sign_in @super_admin
    get bookings_url, params: { day: "2025-08-06" }
    assert_response :success
  # swimming fixture has booking_time_slots for 2025-08-06 with purpose "Bơi thư giãn"
  assert_match Regexp.new("Bơi thư giãn"), @response.body
  end

  test "update via params[:status] sets approved_by and status" do
    sign_in @super_admin
    patch booking_url(@booking), params: { status: "approved" }
    assert_redirected_to bookings_url
    @booking.reload
    assert_equal "approved", @booking.status
    assert_equal @super_admin.id, @booking.approved_by_id
  end

  test "update failure redirects with alert when invalid booking params" do
    sign_in @super_admin
    # Send invalid params (missing purpose) to make update fail validation
    patch booking_url(@booking), params: { booking: { purpose: "" } }

  assert_redirected_to bookings_path
  # Expect purpose presence validation message
  assert_match Regexp.new("Purpose can't be blank"), flash[:alert].to_s
  end
end
