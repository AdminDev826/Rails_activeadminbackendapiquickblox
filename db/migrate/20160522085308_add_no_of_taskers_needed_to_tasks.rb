class AddNoOfTaskersNeededToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :taskers_needed, :integer
  end
end
