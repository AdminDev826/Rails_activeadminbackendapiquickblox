class AddStatusToTaskWorkOffers < ActiveRecord::Migration
  def change
  	add_column :task_work_offers, :status, :string, default: 'pending'
  	add_column :task_work_offers, :confirmation_key, :string
  end
end
