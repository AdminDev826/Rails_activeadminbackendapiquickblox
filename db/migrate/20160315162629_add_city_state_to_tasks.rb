class AddCityStateToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :city, :string
  	add_column :tasks, :state, :string
  	add_column :tasks, :country, :string
  	add_column :tasks, :zipcode, :string
  end
end
