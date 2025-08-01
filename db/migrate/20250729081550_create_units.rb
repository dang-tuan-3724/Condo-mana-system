class CreateUnits < ActiveRecord::Migration[8.0]
     def change
       create_table :units, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
         t.string :unit_number, null: false
         t.references :condo, null: false, type: :uuid, foreign_key: true
         t.references :house_owner, type: :uuid, foreign_key: { to_table: :users }
         t.integer :floor
         t.decimal :size, precision: 10, scale: 2
         t.timestamps
       end
       add_index :units, [:condo_id, :unit_number], unique: true
     end
end