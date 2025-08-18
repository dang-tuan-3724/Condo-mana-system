class NotificationsController < ApplicationController
  include NotificationHelper
  def index
    authorize Notification
    @notifications = policy_scope(Notification)
  end

  def show
    @notification = Notification.find(params[:id])
    authorize @notification
    @notification.status = "read"
    @notification.save
  end

  def new
  end

  def create
    @notification = Notification.new(notification_params)
    @notification.user = current_user
    authorize @notification

    if @notification.save
      redirect_to @notification, notice: "Notification was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def test
    authorize Notification
  end

  # Test methods cho channels
  def test_user_notification
    authorize Notification
    broadcast_user_notification(
      current_user.id,
      "This is a test user notification at #{Time.current.strftime('%H:%M:%S')}"
    )
    redirect_back(fallback_location: root_path, notice: "User notification sent!")
  end

  def test_admin_notification
    authorize Notification
    broadcast_admin_notification(
      "This is a test admin notification at #{Time.current.strftime('%H:%M:%S')}"
    )
    redirect_back(fallback_location: root_path, notice: "Admin notification sent!")
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def notification_params
    params.require(:notification).permit(:message)
  end
end
