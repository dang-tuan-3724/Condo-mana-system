class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :facility
  belongs_to :approved_by, class_name: "User", optional: true
  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected cancelled] }
  validate :no_overlapping_bookings

  private

  def no_overlapping_bookings
    if Booking.where(facility_id: facility_id)
              .where.not(id: id)
              .where("start_time < ? AND end_time > ?", end_time, start_time)
              .exists?
      errors.add(:base, "Time slot conflicts with an existing booking")
    end
  end
end