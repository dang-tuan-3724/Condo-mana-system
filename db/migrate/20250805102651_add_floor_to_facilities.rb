class AddFloorToFacilities < ActiveRecord::Migration[8.0]
  def change
    add_column :facilities, :floor, :integer
  end
end
