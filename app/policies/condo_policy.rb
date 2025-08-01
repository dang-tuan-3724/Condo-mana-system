class CondoPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    super_admin? || (operation_admin? && user.condo == record)
  end

  def create?
    super_admin?
  end

  def update?
    super_admin? || (operation_admin? && user.condo == record)
  end

  def destroy?
    super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif operation_admin?
        scope.where(id: user.condo_id)
      else
        scope.none
      end
    end
  end
end
