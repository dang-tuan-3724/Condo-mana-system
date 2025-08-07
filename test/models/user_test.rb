require "test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :users, :condos, :units, :unit_members, :facilities
  setup do
    @admin_user = users(:super_admin)
    @user = users(:user_1)
  end
  test "should not save user without email" do
    user = build(:user, email: nil)
    assert_not user.save, "Saved the user without an email"
  end
   test "should not save user with invalid email" do
    user = build(:user, email: "invalid_email")
    assert_not user.save, "Saved the user with an invalid email"
   end

   test "should not save user with duplicate email" do
     duplicate_user = build(:user, email: @user.email)
     assert_not duplicate_user.save, "Saved with a duplicate email"
   end
   test "should not save user with nil password" do
     user = build(:user, password: nil)
     assert_not user.save, "Saved the user without password"
     assert_includes user.errors[:password], "can't be blank"
   end

   test "should not save user with short password" do
     user = build(:user, password: "short")
     assert_not user.save, "Saved the user with a short password"
     assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
   end

   test "should save user with valid attributes" do
      user = build(:user, first_name: "John", last_name: "Doe", email: "john.doe@example.com", password: "password123", password_confirmation: "password123", condo: condos(:vinhomes), role: "house_owner")
      assert user.save, "Failed to save the user with valid attributes"
   end

  test "should allow condo_id nil for all role" do
    user = build(:user, condo_id: nil)
    assert user.save, "Failed to save the user with nil condo_id"
  end

  # test for the association
  test "should have many unit_members" do
    user = users(:house_member)
    assert_includes user.unit_members, unit_members(:unit1_member), "User should have unit_member association"
    assert_includes user.unit_members, unit_members(:unit4_member3), "User should have unit_member association"
    assert_equal 2, user.unit_members.count, "User should have exactly 2 unit_members"
  end


  # test return true for true role
  test "should return true for admin?" do
    user = users(:super_admin)
    user2 = users(:operation_admin)
    assert user.admin?, "User should be an admin"
    assert user2.admin?, "User2 should be an admin"
  end
  test "should return true for superadmin?" do
    user = users(:super_admin)
    assert user.superadmin?, "User should be a super admin"
  end
  test "should return true for operation_admin?" do
    user = users(:operation_admin)
    assert user.operation_admin?, "User should be an operation admin"
  end
  test "should return true for house_owner?" do
    user = users(:house_owner)
    assert user.house_owner?, "User should be a house owner"
  end
  test "should return true for house_member" do
    user = users(:house_member)
    assert user.house_member?, "User should be a house member"
  end
  test "should return false for admin?" do
    user = users(:user_1)
    assert_not user.admin?, "User should not be an admin"
  end


end
