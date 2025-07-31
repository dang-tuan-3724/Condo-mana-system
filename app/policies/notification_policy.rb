class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.id == record.user_id
  end

  def update?
    user.id == record.user_id
  end

  def destroy?
    user.id == record.user_id
  end

  def mark_as_read?
    user.id == record.user_id
  end

  def mark_as_unread?
    user.id == record.user_id
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
