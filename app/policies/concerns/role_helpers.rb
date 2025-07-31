# frozen_string_literal: true

module RoleHelpers
  def super_admin?
    user&.role == "super_admin"
  end

  def operation_admin?
    user&.role == "operation_admin"
  end

  def house_owner?
    user&.role == "house_owner"
  end

  def house_member?
    user&.role == "house_member"
  end

  def admin?
    super_admin? || operation_admin?
  end
end
