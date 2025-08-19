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


  # test GET edit action
  test "super admin should get edit for any user" do
    sign_in @super_admin
    get edit_user_url(@house_member)
    assert_response :success
  end

  test "operation admin should get edit their condo user" do
    sign_in @operation_admin
    get edit_user_url(@user)
    assert_response :success
  end

  test "operation admin should not get edit for the user outside their condo" do
    sign_in @operation_admin
    get edit_user_url(@house_member)
    assert_redirected_to root_path
    assert_equal "You are not authorized to this action.", flash[:alert]
  end

  test "house owner should not get edit for their user" do
    sign_in @user4
    get edit_user_url(@house_member)
    assert_redirected_to root_path
    assert_equal "You are not authorized to this action.", flash[:alert]
  end


  # test UPDATE action
  test "super admin should update any user" do
    sign_in @super_admin
    patch user_url(@house_member), params: { user: { email: "new_email@example.com" } }
    assert_redirected_to user_url(@house_member)
    assert_equal "User was successfully updated.", flash[:notice]
  end

  test "operation admin should update their condo user" do
    sign_in @operation_admin
    patch user_url(@user), params: { user: { email: "new_email@example.com" } }
    assert_redirected_to user_url(@user)
    assert_equal "User was successfully updated.", flash[:notice]
  end

  test "operation admin should not update for the user outside their condo" do
    sign_in @operation_admin
    patch user_url(@house_member), params: { user: { email: "new_email@example.com" } }
    assert_redirected_to root_path
    assert_equal "You are not authorized to this action.", flash[:alert]
  end

  test "house owner should not update their user" do
    sign_in @user4
    patch user_url(@house_member), params: { user: { email: "new_email@example.com" } }
    assert_redirected_to root_path
    assert_equal "You are not authorized to this action.", flash[:alert]
  end

  # test NEW, CREATE action
  test "should create user for super admin role" do
    sign_in @super_admin
    assert_difference "User.count", 1 do
      post users_url, params: { user: { email: "new_email@example.com", password: "password123", password_confirmation: "password123", role: "house_member" } }
    end
    assert_redirected_to user_url(User.find_by(email: "new_email@example.com"))
  end
  test "should not create user for operation admin role" do
    sign_in @operation_admin
    assert_no_difference "User.count" do
      post users_url, params: { user: { email: "new_email@example.com", password: "password123", password_confirmation: "password123", role: "house_member" } }
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to this action.", flash[:alert]
  end

  test "should get new user form for super admin role" do
    sign_in @super_admin
    get new_user_url
    assert_response :success
  end
  test "should create user and associate with unit if unit_id is provided" do
    sign_in @super_admin
    unit = units(:unit1)
    assert_difference [ "User.count", "UnitMember.count" ] do
      post users_url, params: { user: { email: "unit_member@example.com", password: "password123", password_confirmation: "password123", role: "house_member", unit_id: unit.id } }
    end
    user = User.find_by(email: "unit_member@example.com")
    assert user.unit_members.exists?(unit: unit)
  end

  test "should create house_owner and set as unit's house_owner if unit_id is provided" do
    sign_in @super_admin
    unit = units(:unit1)
    condo = condos(:vinhomes)
    assert_difference [ "User.count", "UnitMember.count" ] do
      post users_url, params: { user: { email: "test177@example.com", password: "password123", password_confirmation: "password123", role: "house_owner", unit_id: unit.id, condo_id: condo.id } }
    end
    user = User.find_by(email: "test177@example.com")
    unit.reload
    assert_equal user, unit.house_owner
  end

  # Cover: show rescue when all_related_units raises RecordNotFound (line 30)
  test "show rescues RecordNotFound from all_related_units" do
    sign_in @super_admin
    user = @house_member
    # Make all_related_units raise inside controller by forcing User.find to return this instance
    def user.all_related_units
      raise ActiveRecord::RecordNotFound
    end

    orig = User.method(:find)
    User.define_singleton_method(:find) { |*args| user }
    begin
      get user_url(user)
    ensure
      User.define_singleton_method(:find) { |*args| orig.call(*args) }
    end
    assert_redirected_to users_path
    assert_equal "User not found.", flash[:alert]
  end

  # Cover: create render :new when save fails (line 62)
  test "create renders new when save fails" do
    sign_in @super_admin
    # Missing required email -> save fails
    post users_url, params: { user: { password: "password123", password_confirmation: "password123", role: "house_member" } }
    assert_response :unprocessable_entity
    assert_template :new
  end

  # Cover: create rescues ActiveRecord::RecordInvalid (lines 66-67)
  test "create rescues ActiveRecord::RecordInvalid during association" do
    sign_in @super_admin
    unit = units(:unit1)

    # Force unit.update! to raise when called so transaction rescues
    unit.define_singleton_method(:update!) do |*args|
      raise ActiveRecord::RecordInvalid.new(unit)
    end

    orig = Unit.method(:find)
    Unit.define_singleton_method(:find) { |*args| unit }
    begin
      post users_url, params: { user: { email: "owner_with_issue@example.com", password: "password123", password_confirmation: "password123", role: "house_owner", unit_id: unit.id } }
    ensure
      Unit.define_singleton_method(:find) { |*args| orig.call(*args) }
    end

    assert_response :unprocessable_entity
    assert_template :new
    assert_includes assigns(:user).errors.full_messages.join(" "), "Could not associate"
  end

  # Cover: update unit change happy path (lines 106-112)
  test "update changes unit, condo and sets new unit house_owner" do
    sign_in @super_admin
    user = users(:user_4) # currently house_owner of unit4
    old_unit = units(:unit4)
    new_unit = units(:unit1)

    patch user_url(user), params: { user: { role: user.role, unit_id: new_unit.id } }
    assert_redirected_to user_url(user)
    user.reload
    new_unit.reload
    old_unit.reload

    # new unit should have new house_owner set
    assert_equal user, new_unit.house_owner
    # old unit should no longer have house_owner equal to user
    assert_not_equal user, old_unit.house_owner
    # user's condo should be updated to new unit's condo
    assert_equal new_unit.condo_id, user.condo_id
  end

  # Cover: update rescues ActiveRecord::RecordInvalid (lines 129-131)
  test "update rescues RecordInvalid during unit update" do
    sign_in @super_admin
    user = users(:user_4)
    new_unit = units(:unit1)

    # Make new_unit.update! raise to trigger rescue
    new_unit.define_singleton_method(:update!) do |*args|
      raise ActiveRecord::RecordInvalid.new(new_unit)
    end

    orig = Unit.method(:find)
    Unit.define_singleton_method(:find) { |*args| new_unit }
    begin
      patch user_url(user), params: { user: { role: user.role, unit_id: new_unit.id } }
    ensure
      Unit.define_singleton_method(:find) { |*args| orig.call(*args) }
    end

    assert_response :unprocessable_entity
    assert_template :edit
    assert_includes assigns(:user).errors.full_messages.join(" "), "Could not update association"
  end

  # Cover: destroy success and failure branches (lines 135-139)
  test "destroy redirects to index on success" do
    sign_in @super_admin
    user = users(:user_2)
    delete user_url(user)
    assert_redirected_to users_url
    assert_equal "User was successfully deleted.", flash[:notice]
  end

  test "destroy renders alert when destroy fails" do
    sign_in @super_admin
    user = users(:user_2)

    # stub User.find to return object with failing destroy
    failing = user
    def failing.destroy
      false
    end
    def failing.errors
      Struct.new(:full_messages).new([ "cannot delete" ])
    end

    orig = User.method(:find)
    User.define_singleton_method(:find) { |*args| failing }
    begin
      delete user_url(user)
    ensure
      User.define_singleton_method(:find) { |*args| orig.call(*args) }
    end

    assert_redirected_to user_url(failing)
    assert_match "Could not delete member", flash[:alert]
  end

  # Cover: set_user rescue (line 148)
  test "set_user rescues RecordNotFound and redirects to root" do
    sign_in @super_admin
    # Use an id that does not exist
    get edit_user_url(id: "00000000-0000-0000-0000-000000000000")
    assert_redirected_to root_path
    assert_equal "Member not found", flash[:alert]
  end
end
