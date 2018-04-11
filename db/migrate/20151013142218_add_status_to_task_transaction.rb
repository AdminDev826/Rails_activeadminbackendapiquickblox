class AddStatusToTaskTransaction < ActiveRecord::Migration
  def change
    add_column :task_transactions, :status, :string
  end
end
