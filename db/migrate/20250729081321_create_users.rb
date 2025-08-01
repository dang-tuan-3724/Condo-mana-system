class CreateUsers < ActiveRecord::Migration[8.0]
     def change
       enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

       create_table :users, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
         t.string :email, null: false, default: ""
         t.string :encrypted_password, null: false, default: ""
         t.string :role, null: false, default: "house_member"
         t.string :first_name
         t.string :last_name
         t.string :phone_number
         t.references :condo, type: :uuid, foreign_key: true
         t.string :reset_password_token
         t.datetime :reset_password_sent_at
         t.datetime :remember_created_at
         t.timestamps null: false
       end

       add_index :users, :email, unique: true
       add_index :users, :reset_password_token, unique: true
       add_check_constraint :users, "role IN ('super_admin', 'operation_admin', 'house_owner', 'house_member')", name: "check_user_role"
     end
end