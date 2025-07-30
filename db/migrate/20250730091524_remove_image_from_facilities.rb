class RemoveImageFromFacilities < ActiveRecord::Migration[8.0]
  def change
    remove_column :facilities, :image, :binary
  end
end
