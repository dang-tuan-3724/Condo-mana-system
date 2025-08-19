require "test_helper"

class UnitsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @superadmin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @house_owner = users(:house_owner)
    @unit1 = units(:unit1)
    @unit4 = units(:unit4)
  end

  test "index shows scoped units for operation admin and filters by condo when allowed" do
    sign_in @operation_admin
    get units_url
    assert_response :success
    # attempt to filter by a condo within their scope (vinhomes)
    get units_url, params: { condo_id: condos(:vinhomes).id }
    assert_response :success
  end

  test "index ignore unauthorized condo filter and sets flash alert" do
    sign_in @operation_admin
    # operation_admin manages vinhomes, try filtering by masteri (unauthorized)
    get units_url, params: { condo_id: condos(:masteri).id }
    assert_response :success
    assert_match(/You don't have permission to view units from that condo/, flash.now[:alert].to_s)
  end

  test "show existing unit" do
    sign_in @superadmin
    get unit_url(@unit1)
    assert_response :success
    assert_not_nil assigns(:unit_members)
  end

  test "index json returns minimal unit fields" do
    sign_in @superadmin
    get units_url, as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
    assert body.first.key?("id")
    assert body.first.key?("unit_number")
  end

  test "show missing unit redirects" do
    sign_in @superadmin
    get unit_url(id: SecureRandom.uuid)
    assert_redirected_to units_path
    follow_redirect!
    assert_match(/Unit not found/, flash[:alert].to_s)
  end

  test "new and create unit by superadmin" do
    sign_in @superadmin
    get new_unit_url
    assert_response :success
    assert_difference("Unit.count", 1) do
      post units_url, params: { unit: { unit_number: "Z-999", floor: 9, condo_id: condos(:vinhomes).id, house_owner_id: users(:house_owner).id, size: 80 } }
    end
    assert_redirected_to unit_url(Unit.find_by(unit_number: "Z-999"))
  end

  test "edit update and destroy" do
    sign_in @superadmin
    get edit_unit_url(@unit4)
    assert_response :success
    patch unit_url(@unit4), params: { unit: { unit_number: "D-404-updated" } }
    assert_redirected_to unit_url(@unit4)
    @unit4.reload
    assert_equal "D-404-updated", @unit4.unit_number
    # destroy
    assert_difference("Unit.count", -1) do
      delete unit_url(@unit4)
    end
    assert_redirected_to units_url
  end

  test "edit missing unit redirects" do
    sign_in @superadmin
    get edit_unit_url(id: SecureRandom.uuid)
    assert_redirected_to units_path
    follow_redirect!
    assert_match(/Unit not found/, flash[:alert].to_s)
  end

  test "destroy missing unit redirects" do
    sign_in @superadmin
    delete unit_url(id: SecureRandom.uuid)
    assert_redirected_to units_path
    follow_redirect!
    assert_match(/Unit not found/, flash[:alert].to_s)
  end
end
