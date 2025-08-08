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
  end

  def show
  end

  def new
  end

  def create
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

    if @booking.update(update_params)
      redirect_to bookings_path, notice: "Booking was successfully updated."
    else
      redirect_to bookings_path, alert: "Booking was not updated."
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
    params.require(:booking).permit(:status)
  end
end
