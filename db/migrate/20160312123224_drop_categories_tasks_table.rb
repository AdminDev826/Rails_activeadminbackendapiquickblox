class DropCategoriesTasksTable < ActiveRecord::Migration
  def change
    drop_table :categories_tasks
    add_column :tasks, :category_id, :integer
  end
end
