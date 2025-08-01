class BookingPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    true
  end

  def update?
    admin? || (user == record.user && record.status == "pending")
  end

  def destroy?
    super_admin? || (user == record.user && record.status == %w["pending", "approved"])
  end

  # Define the scope for bookings
  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end

  end
end
