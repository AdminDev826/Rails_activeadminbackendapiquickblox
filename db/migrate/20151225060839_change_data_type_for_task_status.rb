class ChangeDataTypeForTaskStatus < ActiveRecord::Migration
  def change
  	remove_column :tasks, :status
  	remove_column :task_work_offers, :status

  	add_column :tasks, :status, :integer, default: 0
  	add_column :task_work_offers, :status, :integer, default: 0
  end
end
