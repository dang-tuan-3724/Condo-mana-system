class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    # Stream cho user cụ thể, ví dụ: stream_from "notifications:#{current_user.id}"
    Rails.logger.info "User #{current_user.id} subscribed to notifications:#{current_user.id}"
  stream_from "notifications:#{current_user.id}"
  end

  def unsubscribed
    # Cleanup nếu cần
    Rails.logger.info "User #{current_user&.id} unsubscribed from notifications"
  end
end
