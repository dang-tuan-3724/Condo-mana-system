class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :facility
  belongs_to :approved_by, class_name: "User", optional: true
  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected cancelled] }
  validate :no_overlapping_bookings
  validate :booking_within_facility_hours
  validate :booking_aligns_with_time_slots

  private

  def no_overlapping_bookings
    if Booking.where(facility_id: facility_id, status: [ "approved", "pending" ])
              .where.not(id: id)
              .where("start_time < ? AND end_time > ?", end_time, start_time)
              .exists?
      errors.add(:base, "Time slot conflicts with an existing booking")
    end
  end

  def booking_within_facility_hours
    # Validate booking phải nằm trong khung giờ hoạt động
  end

  def booking_aligns_with_time_slots
    # Validate booking phải align với time slots (1 tiếng)
  end
end
