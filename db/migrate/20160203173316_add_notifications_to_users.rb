class AddNotificationsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :notify_task_bids, :boolean, :default => false
  	add_column :users, :notify_task_assigned, :boolean, :default => false
  	add_column :users, :push_notify_allowed, :boolean, :default => false
  end
end
