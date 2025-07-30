class CreateUnitMembers < ActiveRecord::Migration[8.0]
     def change
       create_table :unit_members, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
         t.references :unit, null: false, type: :uuid, foreign_key: true
         t.references :user, null: false, type: :uuid, foreign_key: true
         t.timestamps
       end
       add_index :unit_members, [:unit_id, :user_id], unique: true
     end
end