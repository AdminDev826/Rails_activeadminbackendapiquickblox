class AddAcceptedAtToTaskWorkOffers < ActiveRecord::Migration
  def change
  	add_column :task_work_offers, :accepted_at, :datetime
  end
end
