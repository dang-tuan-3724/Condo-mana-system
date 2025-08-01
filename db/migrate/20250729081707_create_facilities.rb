class CreateFacilities < ActiveRecord::Migration[8.0]
  def change
    create_table :facilities, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :name, null: false
      t.references :condo, null: false, type: :uuid, foreign_key: true
      t.text :description
      t.jsonb :availability_schedule, default: {}, null: false
      t.timestamps
    end
    add_index :facilities, [:condo_id, :name], unique: true
  end
end
