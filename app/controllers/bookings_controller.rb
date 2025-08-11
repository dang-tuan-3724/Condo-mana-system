require "json"

class BookingsController < ApplicationController
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

    # Parse booking_time_slots nếu nó là string JSON
    if @booking.booking_time_slots.is_a?(String)
      begin
        @booking.booking_time_slots = JSON.parse(@booking.booking_time_slots)
        Rails.logger.info "Parsed booking_time_slots: #{@booking.booking_time_slots.inspect}"
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parse error: #{e.message}"
        @booking.errors.add(:booking_time_slots, "Invalid JSON format")
      end
    end

    Rails.logger.info "Booking params: #{@booking.attributes.inspect}"

    authorize @booking

    if @booking.save
      # Gửi job để xử lý xung đột booking
      BookingConflictResolutionJob.perform_later(@booking.id)
      redirect_to facility_path(@booking.facility), notice: "Booking request was successfully created and is pending approval."
    else
      Rails.logger.error "Booking validation errors: #{@booking.errors.full_messages}"
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

    # Handle both nested and top-level status param
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
      redirect_to bookings_path, notice: "Booking was successfully updated."
    else
      Rails.logger.error "Booking update failed. Errors: #{@booking.errors.full_messages}"
      Rails.logger.error "Update params: #{update_params.inspect}"
      Rails.logger.error "Current booking status: #{@booking.status}"
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
