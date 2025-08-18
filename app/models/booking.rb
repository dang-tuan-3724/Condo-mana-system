class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :facility
  belongs_to :approved_by, class_name: "User", optional: true

  validates :status, inclusion: { in: %w[pending approved rejected cancelled] }
  validates :booking_time_slots, presence: true
  validates :purpose, presence: true
  validate :validate_booking_time_slots_format
  validate :no_overlapping_bookings
  validate :booking_within_facility_hours
  # Val xem giờ có nằm trong giờ hoạt động của fac không
  # Chỉ validate khi tạo mới, không cần validate khi update status

  # Callbacks để cập nhật facility availability
  after_create :remove_time_slots_from_facility_on_create
  after_update :update_facility_availability, if: :saved_change_to_status?
  after_destroy :restore_facility_availability

  scope :recent_first, -> { order(created_at: :desc) }
  scope :pending_expired, -> { where(status: "pending", created_at: ..1.day.ago) }

  private

  def validate_booking_time_slots_format
    return unless booking_time_slots.present?

    unless booking_time_slots.is_a?(Hash)
      errors.add(:booking_time_slots, "must be a valid JSON object")
      return
    end

    booking_time_slots.each do |day, time_slots|
      unless time_slots.is_a?(Array) && time_slots.all? { |slot| slot.is_a?(String) }
        errors.add(:booking_time_slots, "time slots for #{day} must be an array of strings")
      end
    end
  end

  def no_overlapping_bookings
    # Skip validation khi chỉ update status (không thay đổi time slots)
    return if persisted? && !booking_time_slots_changed?
    return unless booking_time_slots.present?

    booking_time_slots.each do |day, time_slots|
      time_slots.each do |time_slot|
        overlapping_bookings = Booking.where(facility_id: facility_id, status: [ "approved", "pending" ])
                                     .where.not(id: id)
                                     .where("booking_time_slots -> ? @> ?", day, "[\"#{time_slot}\"]")

        if overlapping_bookings.exists?
          errors.add(:base, "Time slot '#{time_slot}' on #{day} conflicts with an existing booking")
        end
      end
    end
  end

  def booking_within_facility_hours
    # Skip validation khi đang update booking (chỉ validate khi tạo mới)



    return if persisted? # Đã tồn tại thì không cần validate - persisted là tồn tại á
    return unless booking_time_slots.present? && facility&.availability_schedule.present?

    booking_time_slots.each do |day, time_slots|
      # Kiểm tra xem facility có hoạt động vào ngày này không
      available_slots = facility.availability_schedule[day]

      if available_slots.blank?
        errors.add(:base, "Facility is not available on #{day}")
        next
      end

      # Kiểm tra từng time slot có trong availability_schedule không
      time_slots.each do |time_slot|
        if !available_slots.include?(time_slot)
          errors.add(:base, "Time slot '#{time_slot}' is not available on #{day}")
        end
      end
    end
  end

  def remove_time_slots_from_facility_on_create
    # Xóa time slots ngay khi booking được tạo (pending)
    remove_time_slots_from_facility
  end
  def remove_time_slots_from_facility
    facility_schedule = facility.availability_schedule.dup
    # phải dùng dup để tạo một shallow copy, nếu không dùng dup thì 2 cái sẽ trỏ tới cùng 1 con pikachu ở trong bộ nhớ, nếu cái "bản sao" thay đổi thì sẽ làm con pikachu đó thay đổi. Măc dù hàm này cuối cùng cũng sẽ thay đổi pikachu trên bộ nhớ nhưng thao tác trên bản sao rồi cập nhật lên bản gốc sẽ an toàn hơn.

    booking_time_slots.each do |date, time_slots|
      if facility_schedule[date].present?
        # Xóa các time slots đã được booking
        facility_schedule[date] = facility_schedule[date] - Array(time_slots)
        # Xóa ngày nếu không còn time slots nào
        facility_schedule.delete(date) if facility_schedule[date].empty?
      end
    end

    facility.update_column(:availability_schedule, facility_schedule)
  end
  def update_facility_availability
    return unless booking_time_slots.present?

    # Không cần xử lý gì thêm vì time slots đã được xóa khi tạo booking
    # Chỉ cần khôi phục khi status thay đổi từ pending/approved sang rejected/cancelled
    if status.in?([ "rejected", "cancelled" ]) && status_before_last_save.in?([ "pending", "approved" ])
      restore_time_slots_to_facility
    end
  end

  def restore_facility_availability
    return unless booking_time_slots.present?

    # Khôi phục time slots khi booking bị xóa (bất kể status gì)
    restore_time_slots_to_facility
  end



  def restore_time_slots_to_facility
    facility_schedule = facility.availability_schedule.dup

    booking_time_slots.each do |date, time_slots|
      if facility_schedule[date].present?
        # Thêm lại các time slots, sắp xếp và loại bỏ duplicate
        facility_schedule[date] = (facility_schedule[date] + Array(time_slots)).uniq.sort
      else
        # Tạo mới nếu ngày chưa tồn tại
        facility_schedule[date] = Array(time_slots).sort
      end
    end

    facility.update_column(:availability_schedule, facility_schedule)
  end
end
