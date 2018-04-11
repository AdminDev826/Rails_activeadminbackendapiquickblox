class AddDimensionsToCategoryImages < ActiveRecord::Migration
  def change
    add_column :category_images, :width, :string
    add_column :category_images, :height, :string
  end
end
