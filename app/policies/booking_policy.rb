class BookingPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return true if super_admin?
    return true if operation_admin? && user.condo_id == record.facility.condo_id

    # Người dùng chỉ có thể xem booking của mình
    user.present? && record.user_id == user.id
  end

  def create?
    true
  end

  def update?
    return true if super_admin?
    true if operation_admin? && user.condo_id == record.facility.condo_id
  end

  def destroy?
    return true if super_admin?
    return true if operation_admin? && user.condo_id == record.facility.condo_id

    # Người dùng chỉ có thể xem booking của mình
    user.present? && record.user_id == user.id && record.status == %w["pending", "approved"]
  end

  # Define the scope for bookings
  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif operation_admin?
        scope.joins(:facility).where(facilities: { condo_id: user.condo_id }).or(scope.where(user_id: user.id))
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
