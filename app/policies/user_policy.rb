class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if super_admin?
    return true if operation_admin? && user.condo_id == record.condo_id
    return true if user == record

    # House owner và house member có thể xem thành viên cùng unit
    if house_owner? || house_member?
      unit_ids = user.unit_members.pluck(:unit_id)
      user_ids_in_same_units = UnitMember.where(unit_id: unit_ids).pluck(:user_id)
      return user_ids_in_same_units.include?(record.id)
    end

    false
  end

  def create?
    super_admin?
  end

  def update?
    super_admin? || user == record
  end

  def destroy?
    return false unless record.is_a?(User)
    (super_admin? && !(record == user)) || (operation_admin? && user.condo_ids.include?(record.condo_id) && record.role != "super_admin")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif operation_admin?
        # Operation admin chỉ xem được users của condo họ quản lý
        scope.where(condo_id: user.condo_id).where.not(role: "super_admin")
      elsif house_owner? || house_member?
        # House owner và house member chỉ xem được thành viên cùng unit
        unit_ids = user.unit_members.pluck(:unit_id)
        user_ids_in_same_units = UnitMember.where(unit_id: unit_ids).pluck(:user_id)
        scope.where(id: user_ids_in_same_units)
      else
        scope.where(id: user.id)
      end
    end
  end
end
