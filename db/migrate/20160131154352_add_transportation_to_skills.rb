class AddTransportationToSkills < ActiveRecord::Migration
  def change
  	add_column :skills, :transportation, :text
  end
end
