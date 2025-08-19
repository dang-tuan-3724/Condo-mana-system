require "test_helper"

class UnitMembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @house_owner = users(:house_owner)
  @house_member = users(:house_member)
  @new_user = users(:user_2)
    @unit1 = units(:unit1)
  end

  test "create unit member via unit_member request flow (authorized)" do
    sign_in @house_owner
    # simulate adding existing user (house_member) to unit1
    assert_difference("UnitMember.count", 1) do
      post unit_members_path, params: { unit_member: { user_id: @new_user.id, unit_id: @unit1.id } }
    end
    assert_redirected_to unit_path(@unit1)
    follow_redirect!
    assert_match(/Member added successfully/, flash[:notice].to_s)
  end

  test "destroy unit member (authorized)" do
    # use existing fixture unit1_member
    um = unit_members(:unit1_member)
    sign_in users(:house_owner)
    assert_difference("UnitMember.count", -1) do
      delete unit_member_path(um)
    end
    assert_redirected_to unit_path(um.unit)
    follow_redirect!
    assert_match(/Member removed from unit/, flash[:notice].to_s)
  end

  test "create unauthorized should be blocked by policy" do
    sign_in users(:house_member)
    post unit_members_path, params: { unit_member: { user_id: @house_member.id, unit_id: @unit1.id } }
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/You are not authorized to this action/, flash[:alert].to_s)
  end
end
