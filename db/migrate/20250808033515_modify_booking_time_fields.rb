class ModifyBookingTimeFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :bookings, :start_time, :datetime
    remove_column :bookings, :end_time, :datetime
    add_column :bookings, :booking_time_slots, :jsonb, default: {}
  end
end
