class AdminNotificationChannel < ApplicationCable::Channel
  def subscribed
    # Chỉ admin mới có thể subscribe channel này
    if current_user&.admin?
      Rails.logger.info "Admin #{current_user.id} subscribed to admin_notifications"
      stream_from "admin_notifications"
    else
      Rails.logger.info "Non-admin user #{current_user&.id} attempted to subscribe to admin channel"
      reject
    end
  end

  def unsubscribed
    # Cleanup nếu cần
    Rails.logger.info "Admin #{current_user&.id} unsubscribed from admin notifications"
  end
end
