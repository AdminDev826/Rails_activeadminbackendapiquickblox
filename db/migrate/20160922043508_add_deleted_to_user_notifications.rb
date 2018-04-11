class AddDeletedToUserNotifications < ActiveRecord::Migration
  def change
    add_column :user_notifications, :deleted, :boolean
  end
end
