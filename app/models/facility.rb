class Facility < ApplicationRecord
  belongs_to :condo
  has_many :bookings, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :condo_id }
  # Validation cho availability_schedule format
  validate :valid_availability_schedule_format

  # Methods để làm việc với time slots
  def available_time_slots_for_day(day_name)
    availability_schedule[day_name.downcase] || []
  end

  def available_at?(date, time_slot)
    # Logic kiểm tra slot có available không
  end

  private

  def valid_availability_schedule_format
    # Validate format của availability_schedule
  end
end
