class FacilityPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif operation_admin?
        scope.where(condo_id: user.condo_id)
      else
        # House members can see facilities of their condo
        scope.where(condo_id: user.condo_id)
      end
    end
  end
end
