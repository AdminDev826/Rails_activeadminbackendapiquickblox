class AddPaypalPayerIdTaskWorkOffers < ActiveRecord::Migration
  def change
  	add_column :task_work_offers, :paypal_payer_id, :string
  end
end
