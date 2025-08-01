class AddImageToFacilities < ActiveRecord::Migration[8.0]
  def change
    add_column :facilities, :image, :binary
  end
end
