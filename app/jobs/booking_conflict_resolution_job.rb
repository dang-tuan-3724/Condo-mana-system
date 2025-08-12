class BookingConflictResolutionJob < ApplicationJob
  queue_as :booking

  def perform(booking_id)
    booking = Booking.find(booking_id)
    return nil if booking.status != "pending"

    # Re-check overlapping to handle race condition
    conflicts = []
    booking.booking_time_slots.each do |day, time_slots|
      time_slots.each do |time_slot|
        overlapping = Booking.where(facility_id: booking.facility_id, status: [ "approved", "pending" ])
                             .where.not(id: booking.id)
                             .where("booking_time_slots -> ? @> ?", day, "[\"#{time_slot}\"]")
        conflicts << { day: day, time_slot: time_slot } if overlapping.exists?
      end
    end
    if conflicts.any?
      conflict = conflicts.first
      # Log conflict instead of redirect since this is a background job
      Rails.logger.info "Booking #{booking.id} has conflicts: Time slot '#{conflict[:time_slot]}' on #{conflict[:day]} conflicts with an existing booking"
      # Notify the user about the conflict - implement later.
    else
      # Notify the admin - implement later.
    end
  end
end
