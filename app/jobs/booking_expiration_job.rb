class BookingExpirationJob < ApplicationJob
  queue_as :booking

  def perform
    expired_bookings = Booking.pending_expired
    return nil if expired_bookings.empty?

    expired_bookings.each do |booking|
      booking.update(status: "approved")
      # Notify for user and admin - implement later
    end

  end
end
