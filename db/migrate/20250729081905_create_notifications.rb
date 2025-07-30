class CreateNotifications < ActiveRecord::Migration[8.0]
     def change
       create_table :notifications, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
         t.references :user, null: false, type: :uuid, foreign_key: true
         t.string :message, null: false
         t.string :status, default: "unread", null: false
         t.string :category
         t.uuid :reference_id
         t.string :reference_type
         t.timestamps
       end
       add_index :notifications, [:reference_id, :reference_type]
       add_check_constraint :notifications, "status IN ('unread', 'read')", name: "check_notification_status"
     end
end
