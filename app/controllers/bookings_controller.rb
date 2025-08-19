require "json"

class BookingsController < ApplicationController
  include NotificationHelper
  def index
    authorize Booking
    @bookings = policy_scope(Booking)
    if params[:search].present?
      search = params[:search]
      @bookings = @bookings.joins(:facility, :user).where(
        "facilities.name ILIKE :q OR users.email ILIKE :q",
        q: "%#{search}%"
      )
    end
    if params[:status].present?
      @bookings = @bookings.where(status: params[:status])
    end
    if params[:day].present?
      @bookings = @bookings.select { |b| b.booking_time_slots.keys.include?(params[:day]) }
    end
    # Sort newest first
    if @bookings.is_a?(ActiveRecord::Relation)
      @bookings = @bookings.recent_first
      # binh thuong no se tra ve active record
    else
      @bookings = @bookings.sort_by(&:created_at).reverse
      # nhung sau khi @bookings.select thi no lai tra ve Array
    end
  end

  def show
  end

  def new
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user = current_user
    @booking.status = "pending"

    # Parse booking_time_slots nếu nó là string JSONB
    if @booking.booking_time_slots.is_a?(String)
      begin
        @booking.booking_time_slots = JSON.parse(@booking.booking_time_slots)
        Rails.logger.info "Parsed booking_time_slots: #{@booking.booking_time_slots.inspect}"
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parse error: #{e.message}"
  @booking.errors.add(:booking_time_slots, "Invalid JSON format")
  # Prevent model validators that expect a Hash from raising by normalizing to nil
  @booking.booking_time_slots = nil
      end
    end

    Rails.logger.info "Booking params: #{@booking.attributes.inspect}"

    authorize @booking

    if @booking.save
      # Gửi job để xử lý xung đột booking
      BookingConflictResolutionJob.perform_later(@booking.id)

      # Tạo notification cho user
      Notification.create!(
        user: @booking.user,
        message: "Your booking for facility ##{@booking.facility.name} was created and is pending approval.",
        status: "unread",
        category: "booking",
        reference: @booking
      )

      # Broadcast notification cho user
      Rails.logger.info "Broadcasting user notification to user #{@booking.user.id}"
      broadcast_user_notification(@booking.user.id, "Your booking was created successfully!")
      Rails.logger.info "Broadcasting admin notification"
      broadcast_admin_notification("New booking requires approval from #{@booking.user.email}")

      redirect_to facility_path(@booking.facility), notice: "Booking request was successfully created and is pending approval."
    else
      # Lấy facility từ params nếu @booking.facility nil
      facility_id = @booking.facility_id || params[:booking][:facility_id]
      if facility_id.present?
        redirect_to facility_path(facility_id), alert: "Failed to create booking: #{@booking.errors.full_messages.join(', ')}"
      else
        redirect_to facilities_path, alert: "Failed to create booking: #{@booking.errors.full_messages.join(', ')}"
      end
    end
  end

  def edit
  end

  def update
    @booking = Booking.find(params[:id])
    authorize @booking

    # Handle 2 trường hợp, 1 là nằm trong params (update qua form á), 2 là nằm trong params[:status] (update chỉ trạng thái thôi)
    update_params = if params[:booking].present?
      booking_params
    elsif params[:status].present?
      { status: params[:status] }
    else
      {}
    end

    # Set approved_by khi status thay đổi thành approved
    if update_params[:status] == "approved" && @booking.status != "approved"
      update_params[:approved_by_id] = current_user.id
    end

    if @booking.update(update_params)
      # Tạo notification cho user khi status thay đổi
      if @booking.saved_change_to_status?
        status_message = case @booking.status
        when "approved"
          "Your booking for #{@booking.facility.name} has been approved!"
        when "rejected"
          "Your booking for #{@booking.facility.name} has been rejected."
        when "cancelled"
          "Your booking for #{@booking.facility.name} has been cancelled."
        end

        if status_message
          # Tạo notification trong database
          Notification.create!(
            user: @booking.user,
            message: status_message,
            status: "unread",
            category: "booking",
            reference: @booking
          )

          # Broadcast notification cho user
          Rails.logger.info "Broadcasting status update notification to user #{@booking.user.id}"
          broadcast_user_notification(@booking.user.id, status_message)
        end
      end

      redirect_to bookings_path, notice: "Booking was successfully updated."
    else

      redirect_to bookings_path, alert: "Booking was not updated: #{@booking.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    authorize @booking
    @booking.destroy
    redirect_to bookings_path, notice: "Booking was successfully deleted."
  end
  private

  def booking_params
    params.require(:booking).permit(:status, :purpose, :facility_id, :booking_time_slots, :approved_by_id)
  end
end
