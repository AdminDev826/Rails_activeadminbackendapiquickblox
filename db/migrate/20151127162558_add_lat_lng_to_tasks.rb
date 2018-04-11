class AddLatLngToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :tasks, :longitude, :decimal, :precision => 15, :scale => 10
  end
end
