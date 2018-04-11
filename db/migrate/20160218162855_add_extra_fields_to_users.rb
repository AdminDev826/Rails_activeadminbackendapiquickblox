class AddExtraFieldsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :tag_line, :string
  	add_column :users, :birthday, :date
  	add_column :users, :description, :text
  end
end
