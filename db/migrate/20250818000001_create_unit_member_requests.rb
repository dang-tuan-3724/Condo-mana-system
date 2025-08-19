class CreateUnitMemberRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_member_requests, id: :uuid do |t|
      t.references :unit, type: :uuid, null: false, foreign_key: true
      t.references :sender, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :recipient, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
  add_index :unit_member_requests, [ :unit_id, :recipient_id ], name: 'index_umr_on_unit_and_recipient'
  end
end
