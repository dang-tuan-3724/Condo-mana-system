require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @super_admin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @house_owner = users(:house_owner)
    @house_member = users(:house_member)
    @user = users(:user_1)
    @unit = units(:unit1)
    @condo = condos(:vinhomes)
    @user4 = users(:user_4)
  end

  # test GET index action
  test "super admin should get index" do
    sign_in @super_admin
    get users_url
    assert_response :success
  end

  test "operation admin should get index for their condo" do
    sign_in @operation_admin
    get users_url
    assert_response :success
  end

  test "house owner should not get index" do
    sign_in @house_owner
    get users_url
    assert_response :success
  end
  test "house member should not get index" do
    sign_in @house_member
    get users_url
    assert_response :success
  end

  test "unauthenticated user should redirected to sign in" do
    get users_url
    assert_redirected_to new_user_session_path
  end

  test "index should filter users by condo id" do
    sign_in @super_admin
    get users_url, params: { condo_id: @condo.id }
    assert_response :success
    assert_select "#member-container", count: User.where(condo_id: @condo.id).count
  end

  test "index should search users" do
    sign_in @super_admin
    get users_url, params: { search: @operation_admin.email }
    assert_response :success
    assert_includes @response.body, @operation_admin.email
  end

  # test GET show action
  test "super admin should get show for any user" do
    sign_in @super_admin
    get users_url(@house_member)
    assert_response :success
    assert_includes @response.body, @house_member.email
  end
  test "operation admin should get show their condo user" do
    sign_in @operation_admin
    get users_url(@user)
    assert_response :success
    assert_includes @response.body, @user.email
  end
  test "operation admin should not get show for the user outside their condo" do
    sign_in @operation_admin
    get user_url(@house_member)
    assert_redirected_to root_path
    assert_equal "You are not authorized to this action.", flash[:alert]
  end

  test "house owner should get show for their user" do
    sign_in @user4
    get user_url(@house_member)
    assert_response :success
    assert_includes @response.body, @house_member.email
  end


end
