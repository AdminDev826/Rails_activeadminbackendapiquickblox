class CreateTaskTransactions < ActiveRecord::Migration
  def change
    create_table :task_transactions do |t|
      t.integer :task_id
      t.integer :worker_id
      t.integer :conversation_id
      t.integer :total_cost
      t.datetime :duedate

      t.timestamps null: false
    end
  end
end
