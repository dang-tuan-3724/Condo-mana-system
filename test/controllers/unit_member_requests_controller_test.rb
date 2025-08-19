require "test_helper"

class UnitMemberRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @house_owner = users(:house_owner)
    @house_member = users(:house_member)
    @user1 = users(:user_1)
    @unit = units(:unit1)
    @unit2 = units(:unit2)
    @unit3 = units(:unit3)
  end

  test "house owner can send invitation to existing user" do
    sign_in @house_owner
    assert_difference("UnitMemberRequest.count", 1) do
      post unit_member_requests_path, params: { unit_id: @unit.id, recipient_id: @user1.id }
    end
    assert_redirected_to unit_path(@unit)
    follow_redirect!
  assert_match(/Invitation sent/, flash[:notice].to_s)
  end

  test "non-owner cannot invite" do
    sign_in @house_member
    post unit_member_requests_path, params: { unit_id: @unit.id, recipient_id: @user1.id }
    # Pundit should block this user before controller's owner check
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/You are not authorized to this action/, flash[:alert].to_s)
  end

  test "operation admin is authorized but not owner and sees owner-only alert" do
    sign_in users(:operation_admin)
    assert_difference("UnitMemberRequest.count", 1) do
      post unit_member_requests_path, params: { unit_id: @unit.id, recipient_id: @user1.id }
    end
    assert_redirected_to unit_path(@unit)
    follow_redirect!
    assert_match(/Invitation sent/, flash[:notice].to_s)
  end

  test "create with missing recipient redirects with alert" do
    sign_in @house_owner
  post unit_member_requests_path, params: { unit_id: @unit.id, recipient_id: "non-existent" }
    assert_redirected_to unit_path(@unit)
    follow_redirect!
  assert_match(/Recipient not found/, flash[:alert].to_s)
  end

  test "recipient can accept invitation and become unit member" do
  # create a pending request first
  umr = UnitMemberRequest.create!(unit: @unit3, sender: @house_owner, recipient: @user1)
    sign_in @user1
    post accept_unit_member_request_path(umr)
  assert_redirected_to unit_path(@unit3)
    umr.reload
    assert_equal "accepted", umr.status
  assert UnitMember.exists?(unit: @unit3, user: @user1)
  end

  test "non-recipient cannot accept" do
  umr = UnitMemberRequest.create!(unit: @unit3, sender: @house_owner, recipient: @user1)
    sign_in @house_owner
    post accept_unit_member_request_path(umr)
    assert_redirected_to root_path
    follow_redirect!
  assert_match(/Not authorized/, flash[:alert].to_s)
    umr.reload
    assert_equal "pending", umr.status
  end

  test "recipient can decline invitation" do
  umr = UnitMemberRequest.create!(unit: @unit3, sender: @house_owner, recipient: @user1)
    sign_in @user1
    post decline_unit_member_request_path(umr)
    assert_redirected_to root_path
    umr.reload
    assert_equal "declined", umr.status
  end

  test "non-recipient cannot decline" do
  umr = UnitMemberRequest.create!(unit: @unit3, sender: @house_owner, recipient: @user1)
    sign_in @house_owner
    post decline_unit_member_request_path(umr)
    assert_redirected_to root_path
    follow_redirect!
  assert_match(/Not authorized/, flash[:alert].to_s)
    umr.reload
    assert_equal "pending", umr.status
  end

  test "prevent duplicate pending requests for same recipient and unit" do
    sign_in @house_owner
    # first request
    post unit_member_requests_path, params: { unit_id: @unit.id, recipient_id: @user1.id }
    # second request should fail validation and not create another pending
    assert_no_difference("UnitMemberRequest.count") do
      post unit_member_requests_path, params: { unit_id: @unit.id, recipient_id: @user1.id }
    end
    assert_redirected_to unit_path(@unit)
  end
end
