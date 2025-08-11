class BookingExpirationJob < ApplicationJob
  queue_as :booking

  def perform(booking_id)
    booking = Booking.find(booking_id)
    return nil if booking.status != "pending"

    # Check if the booking has expired
    if booking.created_at < 1.day.ago
      booking.update(status: "expired")
      # Notify the user about the expiration - implement later.
    end
  end
end
