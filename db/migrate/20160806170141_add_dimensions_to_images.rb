class AddDimensionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :width, :string
    add_column :images, :height, :string
  end
end
