class AddCreatedAtToUserNotifications < ActiveRecord::Migration
  def change
    add_column :user_notifications, :type, :string
    add_column :user_notifications, :created_at, :datetime
    add_column :user_notifications, :updated_at, :datetime
  end
end
