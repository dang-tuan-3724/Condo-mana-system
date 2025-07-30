class CreateCondos < ActiveRecord::Migration[8.0]
     def change
      enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
      create_table :condos, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
         t.string :name, null: false
         t.text :address
         t.jsonb :configuration, default: {}, null: false
         t.timestamps
      end
      add_index :condos, :name, unique: true
     end
end
