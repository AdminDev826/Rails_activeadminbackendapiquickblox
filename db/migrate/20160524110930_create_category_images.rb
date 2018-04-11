class CreateCategoryImages < ActiveRecord::Migration
  def change
    create_table :category_images do |t|
    	t.integer :category_id
    	t.string :link

      t.timestamps null: false
    end
  end
end
