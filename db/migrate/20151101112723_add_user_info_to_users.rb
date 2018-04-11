class AddUserInfoToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :phone_number,           :string
  	add_column :users, :notify_message_replies, :boolean, :default => false
  	add_column :users, :notify_comment_replies, :boolean, :default => false
  	add_column :users, :notify_task_status,     :boolean, :default => false
  end
end
