class AddAcceptedOffersCountToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :accepted_offers_count, :integer, default: 0
  end
end
