class AddTransactionResponseToTaskWorkOffers < ActiveRecord::Migration
  def change
    add_column :task_work_offers, :transaction_response, :text
  end
end
