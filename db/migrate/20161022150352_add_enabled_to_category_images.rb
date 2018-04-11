class AddEnabledToCategoryImages < ActiveRecord::Migration
  def change
    add_column :category_images, :enabled, :boolean, default: true
  end
end
