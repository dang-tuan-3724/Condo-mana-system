class CreateBookings < ActiveRecord::Migration[8.0]
     def change
       create_table :bookings, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
         t.references :user, null: false, type: :uuid, foreign_key: true
         t.references :facility, null: false, type: :uuid, foreign_key: true
         t.datetime :start_time, null: false
         t.datetime :end_time, null: false
         t.string :purpose
         t.string :status, default: "pending", null: false
         t.references :approved_by, type: :uuid, foreign_key: { to_table: :users }
         t.timestamps
       end
       add_index :bookings, [:facility_id, :start_time, :end_time], name: "index_bookings_on_time_range"
       add_check_constraint :bookings, "status IN ('pending', 'approved', 'rejected', 'cancelled')", name: "check_booking_status"
     end
end
