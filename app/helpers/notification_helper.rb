# Helper methods để broadcast notifications
module NotificationHelper
  # Broadcast notification cho user cụ thể
  def broadcast_user_notification(user_id, message, type: "info")
    Rails.logger.info "Broadcasting user notification: #{message} to user #{user_id}"
    ActionCable.server.broadcast(
      "notifications:#{user_id}",
      {
        message: message,
        type: type,
        timestamp: Time.current.iso8601
      }
    )
    Rails.logger.info "User notification broadcasted successfully"
  end

  # Broadcast notification cho tất cả admins
  def broadcast_admin_notification(message, type: "alert")
    Rails.logger.info "Broadcasting admin notification: #{message}"
    ActionCable.server.broadcast(
      "admin_notifications",
      {
        message: message,
        type: type,
        timestamp: Time.current.iso8601,
        priority: "high"
      }
    )
    Rails.logger.info "Admin notification broadcasted successfully"
  end

  # Broadcast notification cho tất cả users trong một condo
  def broadcast_condo_notification(condo_id, message, type: "info")
    # Tìm tất cả users trong condo
    users = User.where(condo_id: condo_id)

    users.each do |user|
      broadcast_user_notification(user.id, message, type: type)
    end
  end
end
