class AddTransactionIdToTaskWorkOffers < ActiveRecord::Migration
  def change
  	add_column :task_work_offers, :transaction_id, :string
  	add_column :task_work_offers, :payment_status, :string
  end
end
