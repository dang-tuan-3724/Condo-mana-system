class UnitPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    super_admin? ||
    (operation_admin? && user.condo_id == record.condo_id) ||
    (house_owner? && record.house_owner_id == user.id) ||
    record.unit_members.exists?(user_id: user.id)
  end

  def create?
    super_admin?
  end

  def update?
    super_admin? || (operation_admin? && user.condo_id == record.condo_id)
  end

  def destroy?
   super_admin?
  end

  # Define the scope for units

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif operation_admin?
        scope.where(condo_id: user.condo_id)
      elsif house_owner?
        scope.where(house_owner_id: user.id)
      elsif house_member?
        scope.joins(:unit_members).where(unit_members: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
