require "test_helper"

class FacilitiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @super_admin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @house_owner = users(:house_owner)
    @house_member = users(:house_member)
    @user = users(:user_1)
    @unit = units(:unit1)
    @condo = condos(:vinhomes)
    @vinhomes_pool = facilities(:vinhomes_pool)
    @user4 = users(:user_4)
  end

  test "should get index" do
    get facilities_url
    assert_response :success
  end

  test "should get show" do
    sign_in @user
    get facility_url(@vinhomes_pool)
    assert_response :success
  end

  test "should get new for only superadmin" do
    sign_in @super_admin
    get new_facility_url
    assert_response :success
  end

  test "should get edit for superadmin" do
    sign_in @super_admin
    get edit_facility_url(@vinhomes_pool)
    assert_response :success
  end
  test "should get edit for operation admin" do
    sign_in @operation_admin
    get edit_facility_url(@vinhomes_pool)
    assert_response :success
  end

  test "should update for superadmin" do
    sign_in @super_admin
    patch facility_url(@vinhomes_pool), params: { facility: { name: "Updated Name" } }
    assert_redirected_to facility_url(@vinhomes_pool)
    follow_redirect!
    assert_response :success
    assert_equal "Updated Name", assigns(:facility).name
  end
  test "should update for operation admin" do
    sign_in @operation_admin
    patch facility_url(@vinhomes_pool), params: { facility: { name: "Updated Name" } }
    assert_redirected_to facility_url(@vinhomes_pool)
    follow_redirect!
    assert_response :success
    assert_equal "Updated Name", assigns(:facility).name
  end

  test "should create new fac for superadmin only" do
    sign_in @super_admin
    assert_difference("Facility.count") do
      post facilities_url, params: { facility: { name: "New Facility", condo_id: @condo.id } }
    end
    assert_redirected_to facility_url(Facility.find_by(name: "New Facility"))
  end


  test "should destroy facility for superadmin only" do
    sign_in @super_admin
    facility = Facility.create(name: "Test Facility", condo: @condo)
    assert_difference("Facility.count", -1) do
      delete facility_url(facility)
    end
    assert_redirected_to facilities_url
  end

  test "should search for facility for all user" do
    get facilities_url, params: { search: "Vin" }
    assert_response :success
    facilities = assigns(:facilities)
    assert facilities.any?, "Expected at least one facility to be found"
    query = "vin"
    facilities.each do |f|
      matches = f.name.downcase.include?(query) ||
                f.description.to_s.downcase.include?(query) ||
                (f.condo && f.condo.name.to_s.downcase.include?(query))
      assert matches, "Facility ##{f.id} does not match search query in name, description, or condo name"
    end
  end


  test "build_availability_schedule returns correct schedule hash" do
    controller = FacilitiesController.new
    params = {
      availability_schedule_days: ["2025-08-12", "2025-08-12", "2025-08-13", ""],
      availability_schedule_times: ["07:00-08:00", "08:00-09:00", "09:00-10:00", "10:00-11:00"]
    }
    expected = {
      "2025-08-12" => ["07:00-08:00", "08:00-09:00"],
      "2025-08-13" => ["09:00-10:00"]
    }
    result = controller.send(:build_availability_schedule, params)
    assert_equal expected, result
  end

end
