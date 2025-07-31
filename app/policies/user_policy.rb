class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || user == record
  end

  def create?
    super_admin?
  end

  def update?
    super_admin? || user == record
  end

  def destroy?
    super_admin? || (operation_admin? && user.condo_ids == record.condo_ids && record.role != 'super_admin')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif operation_admin?
        scope.where.not(role: 'super_admin')
      else
        scope.where(id: user.id)
      end
    end
  end
end
