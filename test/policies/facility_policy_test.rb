require "test_helper"

class FacilityPolicyTest < ActiveSupport::TestCase
  def setup
    @super_admin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @house_member = users(:house_member)
    @vinhomes = condos(:vinhomes)
    @masteri = condos(:masteri)
  end

  test "scope resolves all for super admin" do
    scope = Pundit.policy_scope!(@super_admin, Facility)
    ids = scope.pluck(:id).sort
    expected = Facility.all.pluck(:id).sort
    assert_equal expected, ids
  end

  test "scope resolves only condo facilities for operation admin" do
    scope = Pundit.policy_scope!(@operation_admin, Facility)
    ids = scope.pluck(:condo_id).uniq
    assert_equal [ @operation_admin.condo_id ], ids
  end

  test "scope resolves only condo facilities for house member" do
    scope = Pundit.policy_scope!(@house_member, Facility)
    ids = scope.pluck(:condo_id).uniq
    assert_equal [ @house_member.condo_id ], ids
  end
end
