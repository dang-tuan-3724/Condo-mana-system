class NotificationPolicy < ApplicationPolicy
  def index?
    # In index action, record is the Notification class, so don't call instance methods on it
    user.present?
  end

  def show?
    record.user_id == user.id || user.superadmin?
  end

  def test?
    user.present?
  end
  def test_user_notification?
    user.present?
  end
  def test_admin_notification?
    user.present? && user.admin?
  end

  def update?
    record.user_id == user.id || user.superadmin?
  end

  def destroy?
    user.id == record.user_id || user.superadmin?
  end

  def mark_as_read?
    user.id == record.user_id || user.superadmin?
  end

  def mark_as_unread?
    user.id == record.user_id || user.superadmin?
  end

  class Scope < Scope
    def resolve
      if user.superadmin?
        # Superadmin có thể xem tất cả thông báo
        scope.all
      else
        # Các user khác chỉ xem được thông báo của chính mình
        scope.where(user_id: user.id)
      end
    end
  end
end
