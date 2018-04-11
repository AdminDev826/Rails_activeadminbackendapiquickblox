class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.belongs_to :user
      t.string :message
      t.string :device_type
      t.boolean :read_status
    end
  end
end
